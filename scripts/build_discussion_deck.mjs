// Editable five-slide discussion deck, authored from audited aggregate results.
// Use the bundled Node runtime. Set CODEX_PRIMARY_RUNTIME_NODE_MODULES or
// RUNTIME_NODE_MODULES to the dependency-loader path before running this script.
import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
const workspaceDir = process.cwd();
const SKILL_DIR = 'C:/Users/John/.codex/plugins/cache/openai-primary-runtime/presentations/26.1030.10813/skills/presentations';
const runtimeRoot = 'C:/Program Files/WindowsApps/OpenAI.CodexPrimaryRuntime.v26-1030-493-0_26.1030.493.0_x64__3k8sg7r9htsxt/dependencies';
process.env.RUNTIME_NODE_MODULES ??= path.join(runtimeRoot, 'node/node_modules');
const { importRuntimeModule } = await import(pathToFileURL(path.join(SKILL_DIR, 'container_tools/runtime_helpers.mjs')).href);
const { Presentation, PresentationFile } = await importRuntimeModule('@oai/artifact-tool');
const { resolvePresentationFont, applyPresentationChartFont, finalizePresentation } =
  await import(pathToFileURL(path.join(SKILL_DIR, 'container_tools/artifact_tool_utils.mjs')).href);
const fontFamily = resolvePresentationFont();
const buildDir = path.join(workspaceDir, 'outputs/portfolio_deck');
const finalPath = path.resolve(workspaceDir, process.env.DECK_FINAL_PATH ?? 'portfolio/scott_discussion.pptx');
await fs.mkdir(buildDir, { recursive: true });
await fs.mkdir(path.dirname(finalPath), { recursive: true });

// Minimal CSV reader handles quoted fields and embedded commas without extra
// dependencies. The files are aggregate evidence, not hand-entered estimates.
async function readCsv(relativePath) {
  const raw = await fs.readFile(path.join(workspaceDir, relativePath), 'utf8');
  let rows = [], row = [], value = '', quoted = false;
  for (let i=0;i<raw.length;i++) {
    const c = raw[i];
    if (c === '"') { if (quoted && raw[i+1] === '"') { value+='"'; i++; } else quoted=!quoted; }
    else if (c===',' && !quoted) { row.push(value); value=''; }
    else if (c==='\n' && !quoted) { row.push(value.replace(/\r$/, '')); rows.push(row); row=[]; value=''; }
    else value+=c;
  }
  if (value || row.length) { row.push(value); rows.push(row); }
  const headers = rows.shift();
  return rows.filter(row=>row.length===headers.length).map(row=>Object.fromEntries(headers.map((key,i)=>[key,row[i]])));
}
const simulation = await readCsv('data/dynamic_quarterly_simulation_summary.csv');
const empirical = await readCsv('data/quarterly_sensitivity_specifications.csv');
const prediction = await readCsv('data/quarterly_prediction_localities.csv');
const reporting = await readCsv('data/quarterly_sensitivity_reporting_curve.csv');
const selectSimulation = scenario => simulation.find(row=>row.scenario===scenario && row.estimator==='ordinary_history');
const selectedEmpirical = ['primary','early_map_switch','midpoint_map_switch'].map(scenario=>empirical.find(row=>row.scenario===scenario));
if (selectedEmpirical.some(row=>!row) || prediction.length!==9 || reporting.length!==81) throw new Error('Incomplete source evidence');

const deck = Presentation.create({ slideSize: { width:1280, height:720 } });
const colors = { navy:'#17394D', blue:'#326681', orange:'#A9632B', text:'#26333C', gray:'#5E6870', light:'#D7E0E5' };
function text(slide, value, x,y,w,h,size=26,bold=false,color=colors.text,name='text') {
  const shape=slide.shapes.add({geometry:'textbox',name,position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
  shape.text=value;
  shape.text.style={typeface:fontFamily, fontSize:size,bold,color,verticalAlignment:'top',wrap:true};
  return shape;
}
function base(title,index) {
  const slide=deck.slides.add(); slide.background.fill='#FFFFFF';
  text(slide,title,58,42,1164,70,44,true,colors.navy,'slide-title');
  text(slide,String(index),1190,670,35,28,18,false,colors.gray,'page-number');
  return slide;
}
function table(slide, values, x,y,w,h,widths) {
  const table=slide.tables.add({rows:values.length,columns:values[0].length,left:x,top:y,width:w,height:h,values,columnWidths:widths});
  table.borders.assign({fill:colors.light,width:1,style:'solid'});
  for(let r=0;r<values.length;r++) for(let c=0;c<values[0].length;c++) {
    const cell=table.getCell(r,c);
    cell.fill=r===0?colors.blue:(r%2===0?'#F2F6F8':'#FFFFFF');
    cell.text.style={typeface:fontFamily,fontSize:25,color:r===0?'#FFFFFF':colors.text,bold:r===0};
  }
  return table;
}
function chartFont(chart) { applyPresentationChartFont(chart,{fontFamily}); return chart; }
const repo='https://github.com/LystadJS/UN-Peacekeeping';

// 1. Design and the audit-driven narrowing of the original question.
{
  const slide=deck.slides.add(); slide.background.fill='#FFFFFF';
  text(slide,'Protection or\napparent protection?',58,45,1100,145,58,true,colors.navy,'slide-title');
  text(slide,'A quarterly MONUSCO research pilot',62,204,1120,54,34,false,colors.blue);
  text(slide,'How does listed deployment strength relate to subsequent recorded violence, conditional on prior conflict history?',62,290,680,126,31,true);
  text(slide,'Eastern DRC, 2016–2023\nRecorded UCDP one-sided violence events\nCommon within-locality association',62,452,690,130,27);
  table(slide,[['Audited sample','N'],['Candidate localities','19'],['Complete exposure','9'],['Locality-quarters','288'],['Retained events','1,248']],810,290,410,300,[290,120]);
  text(slide,'Unknown listing stays unknown. Complete exposure requires maps up to five months old.',62,623,1130,51,23,false,colors.gray);
  text(slide,'John Lystad | Prepared for discussion with Marc A. Scott | 6 November 2026',62,679,1100,24,17,false,colors.gray);
  slide.speakerNotes.text=`This pilot began with a heterogeneity question. The audit narrowed it to a common within-locality association because deployment absence could not be certified and binary deployment changes were sparse. Nine of nineteen fixed composites have complete exposure under the five-month map-age rule. The count outcome concerns qualifying lethal organized one-sided violence, not all civilian harm. The coefficient refers to 1,000 additional listed military personnel in the preceding quarter, with within and between components separated. No locality-specific slopes or protection rankings were fitted. This is a methodological application and assessment of inference under stated assumptions.\nSources: ${repo}/blob/main/docs/quarterly_panel_audit.md ; ${repo}/blob/main/docs/quarterly_protocol.md ; UCDP methodology https://www.uu.se/en/department/peace-and-conflict-research/research/ucdp/ucdp-methodology.html ; Geo-PKO https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset`;
}
// 2. Native coverage chart keeps the known-truth simulation visible.
{
  const slide=base('Simulation recovery under known truth',2);
  text(slide,'True log-count slope −0.30 in the three scenarios shown',62,119,1120,48,27,false,colors.gray);
  const rows=['favorable','selection','differential_recording'].map(selectSimulation);
  chartFont(slide.charts.add('bar',{position:{left:55,top:184,width:770,height:388},categories:['Favorable','Selection','Reporting'],series:[{name:'95% interval coverage',values:rows.map(row=>+row.coverage),fill:colors.blue}],barOptions:{direction:'column',grouping:'clustered',gapWidth:90},hasLegend:false,title:'95% interval coverage',titleTextStyle:{fontSize:26,fill:colors.text},xAxis:{textStyle:{fontSize:25,fill:colors.text},line:{fill:colors.light,width:1}},yAxis:{min:0,max:1,majorUnit:.2,numberFormatCode:'0%',textStyle:{fontSize:23,fill:colors.gray},majorGridlines:{fill:colors.light,width:1}},dataLabels:{showValue:true,position:'outEnd',numberFormatCode:'0.0%',textStyle:{fontSize:25,bold:true,fill:colors.navy}}}));
  text(slide,'Each adverse scenario biases the slope upward by about 0.31.',865,214,345,155,29,true,colors.navy);
  text(slide,'Mean estimates approach zero despite a true slope of −0.30.',865,389,345,130,27);
  text(slide,'200 replications per scenario shown. Required favorable and null checks pass under their tested assumptions.',62,610,1140,68,23,false,colors.gray);
  slide.speakerNotes.text=`The dynamic simulation preserves the observed exposure schedule and introduces synthetic outcomes with known truth. The favorable model recovers the imposed common slope with 95.5% interval coverage. Selection responding to prior violence and hidden risk lowers coverage to 68%, and differential recording lowers it to 81%. Mean bias is +0.313 and +0.312 respectively. The dynamic exercise includes 1,400 fits on 1,200 generated panels, because two estimators use the same 200 prehistory panels. A separate earlier core experiment had 800 fits. Required ordinary-model gates also include correlated-prehistory and matched-null scenarios. Passing those finite-replication checks does not establish uniform validity. This is evidence about methods under explicit mechanisms, not an estimate of the actual DRC reporting process.\nSource: ${repo}/blob/main/docs/dynamic_quarterly_results.md and data/dynamic_quarterly_simulation_summary.csv.\nResearch connection: Scott, Pennoni and Bórquez (2026), https://doi.org/10.3390/e28070730 concerns uncertainty conditional on history. This pilot uses count models and does not implement that paper's sequence decomposition.`;
}
// 3. Native table displays intervals rather than implying a clear direction.
{
  const slide=base('An imprecise common deployment association',3);
  text(slide,'Per 1,000 listed personnel: count ratio 0.876 [95% CI 0.463, 1.656]',62,120,1150,50,29,true,colors.blue);
  const names=['Primary quarterly','Early map switch','Midpoint map switch'];
  const values=[['Deployment timing','Log-count slope','95% Wald interval'],...selectedEmpirical.map((r,i)=>[names[i],(+r.estimate).toFixed(3),`[${(+r.lower_95).toFixed(3)}, ${(+r.upper_95).toFixed(3)}]`])];
  table(slide,values,62,208,1150,250,[510,260,380]);
  text(slide,'All 17 deletion intervals include zero. Omitting 2017 shifts the slope from −0.133 to −0.535.',62,495,1145,81,28);
  text(slide,'Residual lag-two structure remains. The model provides no supported locality rankings.',62,606,1140,64,24,false,colors.gray);
  slide.speakerNotes.text=`The main negative-binomial model has locality random intercepts, province and calendar terms, within and between deployment strength, prior recorded violence, violent-spell duration and the second deployment lag. The interval includes meaningful associations in both directions. Earlier deployment timing assumptions reverse the point sign while their intervals still include zero. All eleven measurement, secondary-outcome and monthly specification intervals cross zero, but the latter two change the estimand and do not have matching simulation validation. All seventeen history-model locality/year deletion intervals also cross zero, although the 2017 deletion is influential. Residual lag-two correlation remains, with Pearson correlation about 0.189. These are conditional model-based intervals, not causal protection effects. No varying locality slopes were fitted.\nSources: ${repo}/blob/main/docs/quarterly_empirical_results.md ; ${repo}/blob/main/docs/quarterly_sensitivity_results.md ; ${repo}/blob/main/docs/quarterly_diagnostics_results.md.`;
}
// 4. Native locality chart makes concentrated predictive performance explicit.
{
  const slide=base('Prediction gains are concentrated',4);
  text(slide,'Mean log-score gain +0.0429 across 180 held-out outcomes',62,116,1140,48,29,true,colors.blue);
  const shortNames=['Beni','Irumu','Kabare','Masisi','Nyiragongo','Rutshuru','Shabunda','Uvira','Walungu'];
  chartFont(slide.charts.add('bar',{position:{left:55,top:178,width:775,height:426},categories:shortNames,series:[{name:'History minus baseline',values:prediction.map(row=>+row.mean_log_score_difference),fill:colors.blue}],barOptions:{direction:'bar',grouping:'clustered',gapWidth:45},hasLegend:false,xAxis:{tickLabelPosition:'low',textStyle:{fontSize:23,fill:colors.text}},yAxis:{title:{text:'History minus baseline log score',textStyle:{fontSize:22,fill:colors.text}},min:-.3,max:.6,majorUnit:.3,numberFormatCode:'0.0',textStyle:{fontSize:22,fill:colors.gray},majorGridlines:{fill:colors.light,width:1}},dataLabels:{showValue:true,position:'outEnd',numberFormatCode:'0.00',textStyle:{fontSize:21,fill:colors.navy}}}));
  text(slide,'History improves\n14 of 20 quarters\n4 of 9 locality averages',865,210,340,140,28,true,colors.navy);
  text(slide,'Removing Irumu’s scores reverses the average gain.',865,392,340,112,28);
  text(slide,'Retrospective, one-quarter-ahead evaluation. Training-only centering. Plug-in intervals omit parameter uncertainty.',62,619,1140,68,23,false,colors.gray);
  slide.speakerNotes.text=`The rolling evaluation trains on twelve quarters initially, then expands to predict each next quarter from 2019 Q1 through 2023 Q4. All forty model fits are usable. Each fold recomputes locality strength means using training data only and uses prior-quarter histories. Both models cover 171 of 180 outcomes with nominal 95% plug-in count intervals. History narrows those intervals, but the average log-score gain is only 0.0429. Only four locality averages improve. Removing Irumu's scores from aggregation, without refitting, gives a gain of −0.0147. This is a performance-concentration check, not a protection ranking. The sample itself was selected with full-period deployment availability, and GED release vintages do not establish real-time availability. Prediction concerns retrospectively recorded violence and excludes parameter and random-effect estimation uncertainty.\nSources: ${repo}/blob/main/docs/quarterly_prediction_results.md ; data/quarterly_prediction_localities.csv ; data/quarterly_prediction_summary.csv.`;
}
// 5. An editable reporting curve accompanies two bounded research questions.
{
  const slide=base('Reporting assumptions and the next study',5);
  text(slide,'The sensitivity curve describes assumed recording differences',62,118,1150,45,27,false,colors.gray);
  chartFont(slide.charts.add('scatter',{position:{left:55,top:183,width:710,height:375},series:[
    {name:'Estimate',xValues:reporting.map(r=>+r.relative_recording_per_1000),values:reporting.map(r=>+r.estimate),line:{fill:colors.blue,width:3},marker:{symbol:'none'}},
    {name:'Lower 95%',xValues:reporting.map(r=>+r.relative_recording_per_1000),values:reporting.map(r=>+r.lower_95),line:{fill:'#8F9AA3',width:1.5},marker:{symbol:'none'}},
    {name:'Upper 95%',xValues:reporting.map(r=>+r.relative_recording_per_1000),values:reporting.map(r=>+r.upper_95),line:{fill:'#8F9AA3',width:1.5},marker:{symbol:'none'}}],scatterOptions:{style:'line'},hasLegend:true,legend:{position:'bottom',overlay:false,textStyle:{fontSize:20,fill:colors.text}},xAxis:{tickLabelPosition:'low',min:.25,max:4,majorUnit:.75,title:{text:'Recording ratio per 1,000 personnel',textStyle:{fontSize:22,fill:colors.text}},numberFormatCode:'0.00',textStyle:{fontSize:21,fill:colors.gray},majorGridlines:null},yAxis:{crossesAt:-2.3,min:-2.3,max:2,majorUnit:1,title:{text:'Conditional log-count slope',textStyle:{fontSize:22,fill:colors.text}},numberFormatCode:'0.0',textStyle:{fontSize:21,fill:colors.gray},majorGridlines:{fill:colors.light,width:1}}}));
  text(slide,'Two questions for discussion',810,190,410,45,28,true,colors.navy);
  text(slide,'Would a prespecified second violence-history lag help, or mainly add instability?',810,253,410,125,26);
  text(slide,'What simulation evidence and deployment variation should precede locality-specific slopes?',810,407,410,130,26);
  text(slide,'Next comparison: one added history term, matched simulation, and rolling prediction under unchanged measurement rules.',62,588,1150,68,25,true,colors.blue);
  text(slide,'The coefficient shift is algebraic. The data do not identify recording probabilities or remove deployment confounding.',62,662,1135,36,19,false,colors.gray);
  slide.speakerNotes.text=`The log-linear observation model assumes a recording-probability ratio per additional 1,000 personnel. The adjusted coefficient is the recorded-event coefficient minus the assumed log ratio, so this curve is an exact algebraic translation. Its point crosses zero at ratio 0.876, and a conditional interval excludes zero only below 0.463 or above 1.656. These are assumed mechanisms, not measured reporting rates. The band conditions on each assumption and does not include uncertainty about which mechanism is correct. A bounded next study could compare one specified extra violence-history lag, motivated by the remaining lag-two residual structure, under matched simulation and the same rolling evaluation. The second question concerns what would justify returning to heterogeneous slopes. These questions connect to Scott's work on histories, uncertainty and usable multilevel methods without claiming an established peacekeeping specialization.\nSources: ${repo}/blob/main/docs/quarterly_sensitivity_results.md ; ${repo}/blob/main/docs/scott_research_connection.md ; https://steinhardt.nyu.edu/people/marc-scott ; https://steinhardt.nyu.edu/priism/what-when-and-whom ; https://doi.org/10.1080/00031305.2026.2627264 .`;
}

// Preserve native evidence and export PNG/layout previews for visual review.
for (const [index,slide] of deck.slides.items.entries()) {
  const stem=`slide-${String(index+1).padStart(2,'0')}`;
  await fs.writeFile(path.join(buildDir,`${stem}.png`),new Uint8Array(await (await deck.export({slide,format:'png',scale:1.5})).arrayBuffer()));
  await fs.writeFile(path.join(buildDir,`${stem}.layout.json`),await (await slide.export({format:'layout'})).text());
}
const candidatePath=path.join(buildDir,'candidate.pptx');
await (await PresentationFile.exportPptx(deck)).save(candidatePath);
const result=await finalizePresentation({workspaceDir,candidatePath,finalPath,
  pythonExecutable:path.join(runtimeRoot,'python/python.exe'),
  integrityValidatorPath:path.join(SKILL_DIR,'container_tools/inspect_presentation_package_integrity.py'),
  layoutValidatorPath:path.join(SKILL_DIR,'container_tools/inspect_presentation_layout_geometry.py'),
  layoutArgs:['--expected-slide-size-emu','12192000,6858000','--validate-heading-fit','--require-native-table-slide','1','--require-native-table-slide','3'],
  explicitTotalSlideCount:5,requiredNativeTableOwnerSlides:[1,3],requiredNativeChartOwnerSlides:[2,4,5],
  materializeLiteralChartWorkbooks:true,
  fontPolicy:{basis:'design',families:[fontFamily]},verifyArtifactToolImport:true,
  receiptPath:path.join(buildDir,`validation-${Date.now()}.json`)});
await fs.writeFile(path.join(buildDir,'build_info.json'),JSON.stringify({fontFamily,slides:5,finalPath,result},null,2));
console.log(`Saved ${finalPath}`);



