"""Reusable helpers for 00_data_wrangling.ipynb.

This module keeps project-root detection, datetime parsing, derived-variable
calculations, QC flag utilities, exclusion-log builders, and summary utilities
outside the notebook. The notebook should contain the execution narrative and
study-specific decisions; reusable mechanics live here.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any, Iterable

import numpy as np
import pandas as pd


def find_project_root(start: str | Path | None = None) -> Path:
    """Find a likely project root by walking upward from ``start``.

    A directory is accepted as project root when it contains both ``data_raw``
    and ``data_processed``, or when it contains an ``.Rproj`` file, or when it
    contains a ``.git`` directory. If no such directory is found, returns
    ``start``.
    """
    start_path = Path(start or Path.cwd()).resolve()
    for candidate in [start_path, *start_path.parents]:
        has_data_raw = (candidate / "data_raw").exists()
        has_data_processed = (candidate / "data_processed").exists()
        has_rproj = any(candidate.glob("*.Rproj"))
        has_git = (candidate / ".git").exists()
        if (has_data_raw and has_data_processed) or has_rproj or has_git:
            return candidate
    return start_path


def ensure_project_paths(project_root: str | Path | None = None) -> dict[str, Path]:
    """Create and return the standard project path dictionary."""
    root = find_project_root(project_root)
    paths = {
        "PROJECT_ROOT": root,
        "DATA_RAW": root / "data_raw",
        "DATA_PROCESSED": root / "data_processed",
        "OUTPUTS": root / "outputs",
        "OUTPUT_LOGS": root / "outputs" / "logs",
        "OUTPUT_TABLES": root / "outputs" / "tables",
    }
    for path in [
        paths["DATA_RAW"],
        paths["DATA_PROCESSED"],
        paths["OUTPUTS"],
        paths["OUTPUT_LOGS"],
        paths["OUTPUT_TABLES"],
    ]:
        path.mkdir(parents=True, exist_ok=True)
    paths["RAW_MASTER_PATH"] = paths["DATA_RAW"] / "masters_data.csv"
    return paths


def normalize_first_choice(value: Any) -> str | pd._libs.missing.NAType:
    """Return clean first-choice labels or ``pd.NA`` if not bright/dark."""
    if pd.isna(value):
        return pd.NA
    value_str = str(value).strip()
    mapping = {
        "C": "bright",
        "c": "bright",
        "Claro": "bright",
        "claro": "bright",
        "BRIGHT": "bright",
        "bright": "bright",
        "E": "dark",
        "e": "dark",
        "Escuro": "dark",
        "escuro": "dark",
        "DARK": "dark",
        "dark": "dark",
    }
    return mapping.get(value_str, pd.NA)


def build_datetime_raw(df: pd.DataFrame) -> pd.Series:
    """Build a raw datetime string from raw date/time columns when available."""
    if {"date_raw", "start_time_raw"}.issubset(df.columns):
        date_s = df["date_raw"].astype("string").fillna("").str.strip()
        time_s = df["start_time_raw"].astype("string").fillna("").str.strip()
        out = (date_s + " " + time_s).str.replace(r"\s+", " ", regex=True).str.strip()
        return out.replace({"": pd.NA, "<NA>": pd.NA})
    if "datetime_raw" in df.columns:
        return df["datetime_raw"].astype("string")
    return pd.Series(pd.NA, index=df.index, dtype="string")


def parse_datetime_robust(series: pd.Series) -> pd.DataFrame:
    """Parse datetimes with standard, compact, and day-first retry strategies.

    Returns a DataFrame with ``datetime_raw``, parsed ``datetime``, parse method,
    and parse-failure flag. This preserves the raw string even when parsing fails.
    """
    raw_s = series.astype("string")
    cleaned = raw_s.str.replace(r"\s+", " ", regex=True).str.strip()
    parsed = pd.to_datetime(cleaned, errors="coerce")
    method = pd.Series("standard", index=series.index, dtype="string")

    failed = parsed.isna() & cleaned.notna()
    if failed.any():
        compact = cleaned[failed].str.replace(r"\s+", "", regex=True)
        compact = compact.apply(
            lambda x: x[:10] + " " + x[10:] if isinstance(x, str) and len(x) > 10 else x
        )
        retry = pd.to_datetime(compact, errors="coerce")
        idx = retry.index[retry.notna()]
        parsed.loc[idx] = retry.loc[idx]
        method.loc[idx] = "compact_retry"

    failed = parsed.isna() & cleaned.notna()
    if failed.any():
        retry_dayfirst = pd.to_datetime(cleaned[failed], errors="coerce", dayfirst=True)
        idx = retry_dayfirst.index[retry_dayfirst.notna()]
        parsed.loc[idx] = retry_dayfirst.loc[idx]
        method.loc[idx] = "dayfirst_retry"

    return pd.DataFrame(
        {
            "datetime_raw": raw_s,
            "datetime": parsed,
            "datetime_parse_method": method.where(parsed.notna(), "failed"),
            "datetime_parse_failed_flag": parsed.isna() & raw_s.notna(),
        }
    )


def safe_divide(numerator: Any, denominator: Any) -> float:
    """Divide safely, preserving missingness and avoiding impossible infinities."""
    if pd.isna(numerator) or pd.isna(denominator):
        return np.nan
    if denominator == 0:
        if numerator == 0:
            return 0.0
        return np.nan
    return float(numerator) / float(denominator)


def compute_mtpc(row: pd.Series) -> float:
    """Compute mean time per bright-side entry/change.

    This derived endpoint is secondary/descriptive because it depends on
    ``time_bright`` and ``num_changes`` and has edge-case behavior when
    ``num_changes == 0``.
    """
    time_bright = row.get("time_bright", np.nan)
    num_changes = row.get("num_changes", np.nan)
    if pd.isna(time_bright) or pd.isna(num_changes):
        return np.nan
    if time_bright == 0:
        return 0.0
    if num_changes == 0:
        return float(time_bright)
    return float(time_bright) / float(num_changes)


def compute_resistance_index(row: pd.Series) -> float:
    """Compute endurance/resistance index from last flux and time in last flux."""
    last_flux = row.get("last_flux", np.nan)
    time_in_last_flux = row.get("time_in_last_flux", np.nan)
    if pd.isna(last_flux) or pd.isna(time_in_last_flux):
        return np.nan
    if last_flux < 0 or time_in_last_flux < 0:
        return np.nan
    flux_sum = sum(range(1, int(last_flux)))
    last_flux_weight = float(last_flux) * float(time_in_last_flux) / 60
    return flux_sum + last_flux_weight


def compute_kc(df: pd.DataFrame) -> pd.Series:
    """Compute Fulton's condition factor-style Kc when weight and length exist."""
    if not {"wt", "ls"}.issubset(df.columns):
        return pd.Series(np.nan, index=df.index)
    valid = df["wt"].notna() & df["ls"].notna() & (df["ls"] != 0)
    values = np.where(valid, (df["wt"] / (df["ls"] ** 3)) * 100, np.nan)
    return pd.Series(values, index=df.index)


def add_iqr_outlier_flag(
    df: pd.DataFrame,
    value_col: str,
    group_cols: Iterable[str],
    flag_col: str,
    min_n: int = 8,
    multiplier: float = 3.0,
) -> pd.DataFrame:
    """Add a conservative IQR outlier flag within available grouping columns."""
    df[flag_col] = False
    if value_col not in df.columns:
        return df

    valid_group_cols = [col for col in group_cols if col in df.columns]
    if not valid_group_cols:
        groups = {"all": df.index}
    else:
        groups = df.groupby(valid_group_cols, dropna=False).groups

    for _, idx in groups.items():
        values = df.loc[idx, value_col].dropna()
        if len(values) < min_n:
            continue
        q1, q3 = values.quantile([0.25, 0.75])
        iqr = q3 - q1
        if iqr <= 0 or pd.isna(iqr):
            continue
        lower = q1 - multiplier * iqr
        upper = q3 + multiplier * iqr
        df.loc[idx, flag_col] = (df.loc[idx, value_col] < lower) | (df.loc[idx, value_col] > upper)
    return df


def get_first_match(df: pd.DataFrame, fish_id: str) -> pd.Series | None:
    """Return the first row matching ``fish_id``, or ``None``."""
    matches = df.loc[df["fish_id"] == fish_id]
    if matches.empty:
        return None
    return matches.iloc[0]


def add_exclusion_event(
    exclusion_events: list[dict[str, Any]],
    row: pd.Series,
    endpoint_or_stage: str,
    exclusion_scope: str,
    exclusion_reason: str,
    exclusion_type: str,
    is_global_exclusion: bool,
    is_endpoint_specific_exclusion: bool,
    retained_in_processed_dataset: bool,
    notes: str = "",
    source_dataset: str = "masters_data.csv",
) -> None:
    """Append a structured exclusion/retention event to ``exclusion_events``."""
    exclusion_events.append(
        {
            "fish_id": row.get("fish_id", pd.NA),
            "battery": row.get("battery", pd.NA),
            "source_dataset": source_dataset,
            "row_index_original": row.get("source_row_index", pd.NA),
            "treatment": row.get("treatment", pd.NA),
            "exposure": row.get("exposure", pd.NA),
            "datetime": row.get("datetime", pd.NaT),
            "endpoint_or_stage": endpoint_or_stage,
            "exclusion_scope": exclusion_scope,
            "exclusion_reason": exclusion_reason,
            "exclusion_type": exclusion_type,
            "is_global_exclusion": bool(is_global_exclusion),
            "is_endpoint_specific_exclusion": bool(is_endpoint_specific_exclusion),
            "retained_in_processed_dataset": bool(retained_in_processed_dataset),
            "notes": notes,
        }
    )


def add_qc_event(
    qc_events: list[dict[str, Any]],
    event_type: str,
    fish_id: str | None = None,
    battery: str | None = None,
    variable: str | None = None,
    old_value: Any = None,
    new_value: Any = None,
    notes: str = "",
) -> None:
    """Append a structured QC event to ``qc_events``."""
    qc_events.append(
        {
            "event_type": event_type,
            "fish_id": fish_id,
            "battery": battery,
            "variable": variable,
            "old_value": old_value,
            "new_value": new_value,
            "notes": notes,
        }
    )


def summarize_battery(df: pd.DataFrame, name: str) -> None:
    """Print a compact, non-inferential battery-level QC summary."""
    print("=" * 80)
    print(name)
    print("=" * 80)
    print(f"Rows: {len(df):,}")

    if "group" in df.columns:
        print("\nRows by group:")
        print(df.groupby("group", dropna=False).size().to_string())

    if {"treatment", "exposure"}.issubset(df.columns):
        print("\nRows by treatment × exposure:")
        print(df.groupby(["treatment", "exposure"], dropna=False).size().to_string())

    key_cols = [
        "first_choice_valid_binary",
        "no_choice_flag",
        "latency",
        "num_changes",
        "time_bright",
        "mtpc",
        "mov_total",
        "dist_total",
        "vel_mean",
        "stratum_pref",
        "attempts",
        "last_flux",
        "time_in_last_flux",
        "resistance_index",
        "Kc",
        "blood_sugar",
        "sex",
    ]
    key_cols = [col for col in key_cols if col in df.columns]
    if key_cols:
        nan_counts = df[key_cols].isna().sum()
        nan_counts = nan_counts[nan_counts > 0]
        print("\nMissingness in key columns:")
        print(nan_counts.to_string() if len(nan_counts) else "No missing values in selected key columns.")

    flag_cols_present = [col for col in df.columns if col.endswith("_flag")]
    if flag_cols_present:
        flag_counts = df[flag_cols_present].sum(numeric_only=True)
        flag_counts = flag_counts[flag_counts > 0].sort_values(ascending=False)
        print("\nActive QC flags:")
        print(flag_counts.to_string() if len(flag_counts) else "No active QC flags.")
    print()
