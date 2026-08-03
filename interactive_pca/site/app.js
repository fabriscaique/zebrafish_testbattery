const scorePath="data/pca_scores.csv",loadingPath="data/pca_loadings.csv";
const treatmentColors={"0.0":"#a7a7a7","0.5":"#5b8db8","1.0":"#c45a4d"};
const exposureSymbols={"1":"circle","24":"square","96":"diamond"};
const domainColors={LDT:"#4f86b4",NTT:"#2a9d8f",RN:"#d2764b","Phys.":"#8b7baa"};
const endpoints=new Set(["time_bright","mtpc","first_choice_binary","latency","num_changes","dist_total","vel_mean","mov_total","stratum_pref","resistance_index","last_flux","attempts","time_in_last_flux","condition_factor"]);
const state={scores:[],loadings:[],camera:null};

function splitLine(line){const cells=[];let value="",quoted=false;for(let i=0;i<line.length;i++){const c=line[i];if(c==='"'&&line[i+1]==='"'&&quoted){value+='"';i++}else if(c==='"')quoted=!quoted;else if(c===","&&!quoted){cells.push(value);value=""}else value+=c}cells.push(value);return cells}
function parseCsv(text){const lines=text.trim().split(/\r?\n/),headers=splitLine(lines.shift());return lines.filter(Boolean).map(line=>{const cells=splitLine(line);return Object.fromEntries(headers.map((h,i)=>[h,cells[i]??""]))})}
function endpoint(row){return row[""]||row.endpoint||row.variable||row.name}
function validate(scores,loadings){if(scores.length!==135)throw Error(`Expected 135 scores; found ${scores.length}.`);if(loadings.length!==14)throw Error(`Expected 14 loadings; found ${loadings.length}.`);const found=new Set(loadings.map(endpoint));if(found.size!==14||[...endpoints].some(x=>!found.has(x)))throw Error("Endpoint set differs from the locked PCA.");for(const row of [...scores,...loadings])for(const pc of ["PC1","PC2","PC3"])if(!Number.isFinite(Number(row[pc])))throw Error(`Invalid ${pc} value.`)}
function checked(selector){return new Set([...document.querySelectorAll(selector)].filter(x=>x.checked).map(x=>x.value))}

function scoreTraces(){if(!document.querySelector("#show-scores").checked)return[];const treatments=checked(".treatment-filter"),exposures=checked(".exposure-filter"),out=[];for(const t of ["0.0","0.5","1.0"])for(const e of ["1","24","96"]){if(!treatments.has(t)||!exposures.has(e))continue;const rows=state.scores.filter(r=>r.treatment===t&&r.exposure===e);out.push({type:"scatter3d",mode:"markers",name:`${t==="0.0"?"CTR":t+"%"} - ${e} h`,x:rows.map(r=>+r.PC1),y:rows.map(r=>+r.PC2),z:rows.map(r=>+r.PC3),customdata:rows.map(r=>[r.fish_id,t,e]),hovertemplate:"Fish %{customdata[0]}<br>Treatment %{customdata[1]}%<br>Exposure %{customdata[2]} h<br>PC1 %{x:.3f}<br>PC2 %{y:.3f}<br>PC3 %{z:.3f}<extra></extra>",marker:{color:treatmentColors[t],symbol:exposureSymbols[e],size:5.5,opacity:.78,line:{color:"#24343e",width:.4}}})}return out}
function loadingTraces(){
  if(!document.querySelector("#show-loadings").checked)return[];
  const domains=checked(".domain-filter"),rows=state.loadings.filter(r=>domains.has(r.domain));
  const scoreMax=Math.max(...state.scores.flatMap(r=>[Math.abs(+r.PC1),Math.abs(+r.PC2),Math.abs(+r.PC3)]));
  const loadingMax=Math.max(...state.loadings.flatMap(r=>[Math.abs(+r.PC1),Math.abs(+r.PC2),Math.abs(+r.PC3)]));
  const scale=scoreMax*.72/loadingMax;
  const lines=rows.map(r=>{
    const x=+r.PC1*scale,y=+r.PC2*scale,z=+r.PC3*scale,color=domainColors[r.domain]||"#333",data=[endpoint(r),r.domain,r.PC1,r.PC2,r.PC3];
    return{type:"scatter3d",mode:"lines+text",name:r.short_label,showlegend:false,x:[0,x],y:[0,y],z:[0,z],text:["",r.short_label],textposition:"top center",customdata:[data,data],hovertemplate:"%{customdata[0]} (%{customdata[1]})<br>PC1 loading %{customdata[2]:.3f}<br>PC2 loading %{customdata[3]:.3f}<br>PC3 loading %{customdata[4]:.3f}<extra></extra>",line:{color,width:7},textfont:{color,size:11}};
  });
  const arrowheads=rows.map(r=>{const x=+r.PC1*scale,y=+r.PC2*scale,z=+r.PC3*scale;return{type:"cone",name:`${r.short_label} arrowhead`,showlegend:false,x:[x],y:[y],z:[z],u:[x*.12],v:[y*.12],w:[z*.12],anchor:"tip",sizemode:"scaled",sizeref:.32,colorscale:[[0,domainColors[r.domain]||"#333"],[1,domainColors[r.domain]||"#333"]],showscale:false,hoverinfo:"skip"}});
  return[...lines,...arrowheads];
}
function render(){const data=[...scoreTraces(),...loadingTraces()],layout={margin:{l:0,r:0,b:0,t:12},paper_bgcolor:"#fff",legend:{orientation:"h",x:0,y:-.04},scene:{xaxis:{title:{text:"PC1 (23.3%)"}},yaxis:{title:{text:"PC2 (17.2%)"}},zaxis:{title:{text:"PC3 (10.3%)"}},aspectmode:"cube",bgcolor:"#fbfcfc",camera:state.camera||{eye:{x:1.45,y:1.45,z:1.1}}},uirevision:"canonical-camera"};Plotly.react("pca-plot",data,layout,{responsive:true,displaylogo:false,scrollZoom:true});document.querySelector("#plot-status").textContent=`${state.scores.length} fish and ${state.loadings.length} vectors loaded from canonical outputs.`}
async function init(){try{const [s,l]=await Promise.all([fetch(scorePath),fetch(loadingPath)]);if(!s.ok||!l.ok)throw Error("Canonical CSV files could not be loaded.");state.scores=parseCsv(await s.text());state.loadings=parseCsv(await l.text());validate(state.scores,state.loadings);render();document.querySelector("#pca-plot").on("plotly_relayout",e=>{if(e["scene.camera"])state.camera=e["scene.camera"]})}catch(error){const status=document.querySelector("#plot-status");status.textContent=`Interactive plot unavailable: ${error.message}`;status.classList.add("error")}}
for(const control of document.querySelectorAll("input"))control.addEventListener("change",render);document.querySelector("#reset-view").addEventListener("click",()=>{state.camera={eye:{x:1.45,y:1.45,z:1.1}};render()});init();
