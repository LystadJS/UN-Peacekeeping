// Editable five-slide discussion deck, authored from audited aggregate results.
// Use the bundled Node runtime. Set CODEX_PRIMARY_RUNTIME_NODE_MODULES or
// RUNTIME_NODE_MODULES to the dependency-loader path before running this script.
import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
const workspaceDir = process.cwd();
const SKILL_DIR = 'C:/Users/John/.codex/plugins/cache/openai-primary-runtime/presentations/26.1104.22356/skills/presentations';
const runtimeRoot = 'C:/Program Files/WindowsApps/OpenAI.CodexPrimaryRuntime.v26-1104-2876-0_26.1104.2876.0_x64__3k8sg7r9htsxt/dependencies';
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
const empirical = await readCsv('data/corrected_panel_model_comparison.csv');
const prediction = await readCsv('data/quarterly_prediction_localities.csv');
const reportingGrid = await readCsv('data/quarterly_sensitivity_reporting_curve.csv');
const selectSimulation = scenario => simulation.find(row=>row.scenario===scenario && row.estimator==='ordinary_history');
const selectedEmpirical = ['original','supported_corrections','mavivi_plus_150'].map(scenario=>empirical.find(row=>row.scenario===scenario));
const corrected = selectedEmpirical[1];
if (!corrected) throw new Error('Missing supported-correction fit');
// Translate the saved corrected coefficient and its conditional interval by
// the assumed log recording ratio. This is algebraic sensitivity, not a refit
// or an estimate of actual recording probabilities. Retain the original grid.
// Twelve significant digits preserve meaningful precision in Excel workbooks.
const reporting = reportingGrid.map(row => ({
  relative_recording_per_1000: +(+row.relative_recording_per_1000).toPrecision(12),
  estimate: +(+corrected.estimate - Math.log(+row.relative_recording_per_1000)).toPrecision(12),
  lower_95: +(+corrected.lower_95 - Math.log(+row.relative_recording_per_1000)).toPrecision(12),
  upper_95: +(+corrected.upper_95 - Math.log(+row.relative_recording_per_1000)).toPrecision(12)
}));
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
  text(slide,'John Lystad | Prepared for discussion with Marc A. Scott | Updated 7 November 2026',62,679,1100,24,17,false,colors.gray);
  slide.speakerNotes.text=`This pilot began with a heterogeneity question. The audit narrowed it to a common within-locality association because deployment absence could not be certified and binary deployment changes were sparse. Nine of nineteen fixed composites have complete exposure under the five-month map-age rule. The count outcome concerns qualifying lethal organized one-sided violence, not all civilian harm. The coefficient refers to 1,000 additional listed military personnel in the preceding quarter, with within and between components separated. No locality-specific slopes or protection rankings were fitted. This is a methodological application and assessment of inference under stated assumptions. The 7 November 2026 update presents separately versioned corrected-panel sensitivity results. Original source files and frozen analysis remain unchanged. Independent human review remains skipped, not completed.\nSources: ${repo}/blob/main/docs/quarterly_panel_audit.md ; ${repo}/blob/main/docs/quarterly_protocol.md ; UCDP methodology https://www.uu.se/en/department/peace-and-conflict-research/research/ucdp/ucdp-methodology.html ; Geo-PKO https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset`;
}
// 2. Native coverage chart keeps the known-truth simulation visible.
{
  const slide=base('Simulation recovery under known truth',2);
  text(slide,'Original experiment: true slope −0.30 in the three scenarios shown',62,119,1120,48,27,false,colors.gray);
  const rows=['favorable','selection','differential_recording'].map(selectSimulation);
  chartFont(slide.charts.add('bar',{position:{left:55,top:184,width:770,height:388},categories:['Favorable','Selection','Reporting'],series:[{name:'95% interval coverage',values:rows.map(row=>+row.coverage),fill:colors.blue}],barOptions:{direction:'column',grouping:'clustered',gapWidth:90},hasLegend:false,title:'95% interval coverage',titleTextStyle:{fontSize:26,fill:colors.text},xAxis:{textStyle:{fontSize:25,fill:colors.text},line:{fill:colors.light,width:1}},yAxis:{min:0,max:1,majorUnit:.2,numberFormatCode:'0%',textStyle:{fontSize:23,fill:colors.gray},majorGridlines:{fill:colors.light,width:1}},dataLabels:{showValue:true,position:'outEnd',numberFormatCode:'0.0%',textStyle:{fontSize:25,bold:true,fill:colors.navy}}}));
  text(slide,'Each adverse scenario biases the slope upward by about 0.31.',865,214,345,155,29,true,colors.navy);
  text(slide,'Mean estimates approach zero despite a true slope of −0.30.',865,389,345,130,27);
  text(slide,'200 replications per scenario shown. Original simulation retained, not rerun on corrected exposures.',62,610,1140,68,23,false,colors.gray);
  slide.speakerNotes.text=`This original simulation was not rerun on corrected exposures. The dynamic simulation uses the original observed exposure schedule as a base and introduces synthetic outcomes with known truth. The selection scenario modifies strength using previous counts and latent risk; favorable and reporting scenarios retain the original schedule. The favorable model recovers the imposed common slope with 95.5% interval coverage. Selection responding to prior violence and hidden risk lowers coverage to 68%, and differential recording lowers it to 81%. Mean bias is +0.313 and +0.312 respectively. The dynamic exercise includes 1,400 fits on 1,200 generated panels, because two estimators use the same 200 prehistory panels. A separate earlier core experiment had 800 fits. Required ordinary-model gates also include correlated-prehistory and matched-null scenarios. Passing those finite-replication checks does not establish uniform validity. This is evidence about methods under explicit mechanisms, not an estimate of the actual DRC reporting process.\nSource: ${repo}/blob/main/docs/dynamic_quarterly_results.md and data/dynamic_quarterly_simulation_summary.csv.\nResearch connection: Scott, Pennoni and Bórquez (2026), https://doi.org/10.3390/e28070730 concerns uncertainty conditional on history. This pilot uses count models and does not implement that paper's sequence decomposition.`;
}
// 3. Native table displays intervals rather than implying a clear direction.
{
  const slide=base('Source corrections leave the result inconclusive',3);
  text(slide,`Corrected count ratio: ${(+corrected.ratio_per_1000).toFixed(3)} [95% CI ${(+corrected.ratio_lower_95).toFixed(3)}, ${(+corrected.ratio_upper_95).toFixed(3)}] per 1,000 personnel`,62,120,1150,50,29,true,colors.blue);
  const names=['Original reference','Supported corrections','Mavivi 2,350 alternative'];
  const values=[['Exposure version','Log-count slope','95% Wald interval'],...selectedEmpirical.map((r,i)=>[names[i],(+r.estimate).toFixed(3),`[${(+r.lower_95).toFixed(3)}, ${(+r.upper_95).toFixed(3)}]`])];
  table(slide,values,62,208,1150,250,[510,260,380]);
  text(slide,'All nine corrected-panel locality-deletion intervals include zero. All 13 fits reproduce in isolation.',62,495,1145,81,28);
  text(slide,'Mavivi analysis total: 2,200. Provider discrepancy cause unverified. Residual dependence remains.',62,606,1140,64,24,false,colors.gray);
  slide.speakerNotes.text=`The supported-correction common within-locality coefficient is -0.1885, with conditional 95% Wald interval [-0.8296, 0.4525], compared with original -0.1326 [-0.7695, 0.5043]. The revision-51 Mavivi alternative gives -0.2102 [-0.8496, 0.4293]. All three retain nine localities, 288 locality-quarters and 1,248 events. The supported shift is -0.0559, about 0.172 original standard errors, a descriptive comparison rather than an equivalence test. Nyamilima geography, adjudicated Rwindi/Nyamilima assignments and Bukavu military coding propagate through strengths, lags and centering. Mavivi map symbols and adjacent rows support a South African sized subtotal of 950 and total 2,200. The provider discrepancy cause remains unverified. The 2,350 alternative is an explicit assumption for revision 51 only. All nine corrected locality-deletion intervals include zero. All 13 fits per run (one baseline, three history fits and nine locality deletions) are numerically usable and reproduced in an isolated environment. The original panel remains unchanged. Corrected lag-two Pearson residual correlation is about 0.187. No locality slopes, causal identification, equivalence conclusion or new forecast validation follow from these results. Exact compound coordinates and actual personnel totals remain uncertified.\nSources: ${repo}/blob/main/docs/corrected_panel_sensitivity_findings.md ; ${repo}/blob/main/docs/corrected_panel_model_results.md ; ${repo}/blob/main/docs/mavivi_subtotal_resolution.md ; ${repo}/blob/main/docs/corrected_panel_construction.md.`;
}
// 4. Native locality chart makes concentrated predictive performance explicit.
{
  const slide=base('Original-panel prediction gains are concentrated',4);
  text(slide,'Mean log-score gain +0.0429 across 180 held-out outcomes',62,116,1140,48,29,true,colors.blue);
  const shortNames=['Beni','Irumu','Kabare','Masisi','Nyiragongo','Rutshuru','Shabunda','Uvira','Walungu'];
  chartFont(slide.charts.add('bar',{position:{left:55,top:178,width:775,height:426},categories:shortNames,series:[{name:'History model minus baseline',values:prediction.map(row=>+row.mean_log_score_difference),fill:colors.blue}],barOptions:{direction:'bar',grouping:'clustered',gapWidth:45},hasLegend:false,xAxis:{tickLabelPosition:'low',textStyle:{fontSize:23,fill:colors.text}},yAxis:{title:{text:'History model minus baseline log score',textStyle:{fontSize:22,fill:colors.text}},min:-.3,max:.6,majorUnit:.3,numberFormatCode:'0.0',textStyle:{fontSize:22,fill:colors.gray},majorGridlines:{fill:colors.light,width:1}},dataLabels:{showValue:true,position:'outEnd',numberFormatCode:'0.00',textStyle:{fontSize:21,fill:colors.navy}}}));
  text(slide,'History model improves\n14 of 20 quarters\n4 of 9 locality averages',865,210,340,140,28,true,colors.navy);
  text(slide,'Removing Irumu’s scores reverses the average gain.',865,392,340,112,28);
  text(slide,'Original rolling validation has not been rerun on corrected exposures. Historical inputs remain uncertified.',62,619,1140,68,23,false,colors.gray);
  slide.speakerNotes.text=`This original-panel evaluation has not been rerun on corrected exposures. The rolling evaluation trains on twelve quarters initially, then expands to predict each next quarter from 2019 Q1 through 2023 Q4. All forty model fits are usable. Each fold recomputes locality strength means using training data only and uses prior-quarter histories. Both models cover 171 of 180 outcomes with nominal 95% plug-in count intervals. The history model narrows those intervals, but the average log-score gain is only 0.0429. Only four locality averages improve. Removing Irumu's scores from aggregation, without refitting, gives a gain of −0.0147. This is a performance-concentration check, not a protection ranking. The sample itself was selected with full-period deployment availability, and the historical investigation has not authenticated a complete information set at the 1 October 2023 cutoff. September coded inputs and later deployment histories remain incomplete. Prediction concerns retrospectively recorded violence and excludes parameter and random-effect estimation uncertainty.\nSources: ${repo}/blob/main/docs/quarterly_prediction_results.md ; data/quarterly_prediction_localities.csv ; data/quarterly_prediction_summary.csv.`;
}
// 5. An editable reporting curve accompanies two bounded research questions.
{
  const slide=base('Reporting assumptions and the next study',5);
  text(slide,'Corrected-panel curve under assumed recording differences',62,118,1150,45,27,false,colors.gray);
  chartFont(slide.charts.add('scatter',{position:{left:55,top:183,width:710,height:375},series:[
    {name:'Estimate',xValues:reporting.map(r=>+r.relative_recording_per_1000),values:reporting.map(r=>+r.estimate),line:{fill:colors.blue,width:3},marker:{symbol:'none'}},
    {name:'Lower 95%',xValues:reporting.map(r=>+r.relative_recording_per_1000),values:reporting.map(r=>+r.lower_95),line:{fill:'#8F9AA3',width:1.5},marker:{symbol:'none'}},
    {name:'Upper 95%',xValues:reporting.map(r=>+r.relative_recording_per_1000),values:reporting.map(r=>+r.upper_95),line:{fill:'#8F9AA3',width:1.5},marker:{symbol:'none'}}],scatterOptions:{style:'line'},hasLegend:true,legend:{position:'bottom',overlay:false,textStyle:{fontSize:20,fill:colors.text}},xAxis:{tickLabelPosition:'low',min:.25,max:4,majorUnit:.75,title:{text:'Recording ratio per 1,000 personnel',textStyle:{fontSize:22,fill:colors.text}},numberFormatCode:'0.00',textStyle:{fontSize:21,fill:colors.gray},majorGridlines:null},yAxis:{crossesAt:-2.3,min:-2.3,max:2,majorUnit:1,title:{text:'Conditional log-count slope',textStyle:{fontSize:22,fill:colors.text}},numberFormatCode:'0.0',textStyle:{fontSize:21,fill:colors.gray},majorGridlines:{fill:colors.light,width:1}}}));
  text(slide,'Two questions for discussion',810,190,410,45,28,true,colors.navy);
  text(slide,'Would a prespecified second violence-history lag help, or mainly add instability?',810,253,410,125,26);
  text(slide,'What simulation evidence and deployment variation should precede locality-specific slopes?',810,407,410,130,26);
  text(slide,'Next comparison: one added history term, matched simulation, and rolling prediction under unchanged measurement rules.',62,588,1150,68,25,true,colors.blue);
  text(slide,'The coefficient shift is algebraic. The data do not identify recording probabilities or remove deployment confounding.',62,662,1135,36,19,false,colors.gray);
  slide.speakerNotes.text=`The log-linear observation model assumes a recording-probability ratio per additional 1,000 personnel. The adjusted coefficient is the recorded-event coefficient minus the assumed log ratio, so this curve is an exact algebraic translation. Using the corrected slope and conditional interval, the point crosses zero at ratio 0.828, and a conditional interval excludes zero only below 0.436 or above 1.572. This translates the saved corrected fit algebraically, without refitting. These are assumed mechanisms, not measured reporting rates. The band conditions on each assumption and does not include uncertainty about which mechanism is correct. A bounded next study could compare one specified extra violence-history lag, motivated by the remaining lag-two residual structure, under matched simulation and the same rolling evaluation. The second question concerns what would justify returning to heterogeneous slopes. These questions connect to Scott's work on histories, uncertainty and usable multilevel methods without claiming an established peacekeeping specialization.\nSources: ${repo}/blob/main/docs/corrected_panel_model_results.md ; ${repo}/blob/main/docs/portfolio_figure_notes.md ; ${repo}/blob/main/docs/quarterly_sensitivity_results.md ; ${repo}/blob/main/docs/scott_research_connection.md ; https://steinhardt.nyu.edu/people/marc-scott ; https://steinhardt.nyu.edu/priism/what-when-and-whom ; https://doi.org/10.1080/00031305.2026.2627264 .`;
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
