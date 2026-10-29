const __vite__mapDeps=(i,m=__vite__mapDeps,d=(m.f||(m.f=["./game-DVHg2UF1.js","./three.core-BLV2Kbbx.js","./renderer-BRPUaEWJ.js","./physics-D5W6iAvK.js"])))=>i.map(i=>d[i]);
(function(){let e=document.createElement(`link`).relList;if(e&&e.supports&&e.supports(`modulepreload`))return;for(let e of document.querySelectorAll(`link[rel="modulepreload"]`))n(e);new MutationObserver(e=>{for(let t of e)if(t.type===`childList`)for(let e of t.addedNodes)e.tagName===`LINK`&&e.rel===`modulepreload`&&n(e)}).observe(document,{childList:!0,subtree:!0});function t(e){let t={};return e.integrity&&(t.integrity=e.integrity),e.referrerPolicy&&(t.referrerPolicy=e.referrerPolicy),t.credentials=e.crossOrigin===`use-credentials`?`include`:e.crossOrigin===`anonymous`?`omit`:`same-origin`,t}function n(e){if(e.ep)return;e.ep=!0;let n=t(e);fetch(e.href,n)}})();var e=[{bass:[116.54,233.08],chord:[233.08,293.66,349.23,440,523.25],melody:[587.33,659.25,698.46,880,783.99,698.46,659.25,587.33],counter:[1174.66,880,1046.5,880,1174.66,1318.51,1046.5,880]},{bass:[130.81,261.63],chord:[261.63,349.23,392,466.16,587.33],melody:[659.25,698.46,783.99,1046.5,880,783.99,698.46,783.99],counter:[1046.5,1174.66,1318.51,1567.98,1318.51,1174.66,1046.5,1174.66]},{bass:[110,220],chord:[220,329.63,392,493.88,523.25],melody:[880,783.99,698.46,659.25,587.33,659.25,698.46,880],counter:[1318.51,1046.5,987.77,880,1046.5,1318.51,1567.98,1318.51]},{bass:[146.83,293.66],chord:[293.66,349.23,440,523.25,659.25],melody:[698.46,587.33,523.25,587.33,659.25,698.46,880,1046.5],counter:[1174.66,1046.5,880,1046.5,1174.66,1396.91,1567.98,1760]},{bass:[98,196],chord:[196,293.66,349.23,440,587.33],melody:[783.99,698.46,587.33,698.46,783.99,880,932.33,880],counter:[1174.66,932.33,880,932.33,1174.66,1396.91,1567.98,1396.91]},{bass:[110,220],chord:[220,277.18,349.23,392,523.25],melody:[880,932.33,880,783.99,698.46,659.25,554.37,659.25],counter:[1318.51,1396.91,1318.51,1108.73,1046.5,880,1108.73,1318.51]},{bass:[146.83,196],chord:[293.66,349.23,440,493.88,659.25],melody:[587.33,698.46,880,783.99,659.25,783.99,987.77,880],counter:[1174.66,1396.91,1760,1567.98,1318.51,1567.98,1975.53,1760]},{bass:[130.81,196],chord:[261.63,329.63,392,466.16,587.33],melody:[783.99,880,932.33,1046.5,1174.66,1046.5,880,698.46],counter:[1567.98,1396.91,1318.51,1174.66,1318.51,1567.98,1760,2093]}],t=class{ctx;master;music;sfx;noiseBuffer=null;musicTimer=0;musicOn=!1;finalLapMode=!1;buffers=new Map;engineOsc1=null;engineOsc2=null;engineFilter=null;engineGain=null;constructor(){this.ctx=new AudioContext,this.master=this.ctx.createGain(),this.music=this.ctx.createGain(),this.sfx=this.ctx.createGain(),this.music.connect(this.master),this.sfx.connect(this.master),this.master.connect(this.ctx.destination)}unlock(){this.ctx.state===`suspended`&&this.ctx.resume()}setFinalLap(e){this.finalLapMode=e}setVolumes(e,t,n=!1){let r=this.ctx.currentTime;this.music.gain.setTargetAtTime(n?0:e*.58,r,.05),this.sfx.gain.setTargetAtTime(n?0:t*.82,r,.05)}async load(e){let t=this.buffers.get(e);if(t)return t;let n=await(await fetch(e)).arrayBuffer(),r=await this.ctx.decodeAudioData(n);return this.buffers.set(e,r),r}playBuffer(e,t=`sfx`,n=!1){let r=this.ctx.createBufferSource();return r.buffer=e,r.loop=n,r.connect(t===`music`?this.music:this.sfx),r.start(),r}getNoiseBuffer(){if(this.noiseBuffer)return this.noiseBuffer;let e=Math.floor(this.ctx.sampleRate*.25),t=this.ctx.createBuffer(1,e,this.ctx.sampleRate),n=t.getChannelData(0);for(let t=0;t<e;t+=1)n[t]=Math.random()*2-1;return this.noiseBuffer=t,t}schedulePercussion(e,t){if(t===`kick`){let t=this.ctx.createOscillator(),n=this.ctx.createGain();t.type=`sine`,t.frequency.setValueAtTime(135,e),t.frequency.exponentialRampToValueAtTime(38,e+.11),n.gain.setValueAtTime(1e-4,e),n.gain.linearRampToValueAtTime(.14,e+.006),n.gain.exponentialRampToValueAtTime(1e-4,e+.13),t.connect(n).connect(this.music),t.start(e),t.stop(e+.14);return}let n=this.ctx.createBufferSource();n.buffer=this.getNoiseBuffer();let r=this.ctx.createBiquadFilter(),i=this.ctx.createGain();t===`snare`?(r.type=`bandpass`,r.frequency.setValueAtTime(1850,e),r.Q.value=1.4,i.gain.setValueAtTime(1e-4,e),i.gain.linearRampToValueAtTime(.065,e+.005),i.gain.exponentialRampToValueAtTime(1e-4,e+.11),n.connect(r).connect(i).connect(this.music),n.start(e),n.stop(e+.12)):(r.type=`highpass`,r.frequency.setValueAtTime(6800,e),i.gain.setValueAtTime(1e-4,e),i.gain.linearRampToValueAtTime(.024,e+.003),i.gain.exponentialRampToValueAtTime(1e-4,e+.045),n.connect(r).connect(i).connect(this.music),n.start(e),n.stop(e+.05))}play(e){if(this.ctx.state!==`running`)return;let t=this.ctx.currentTime,n=(e,n,r,i,a,o=0,s=0)=>{let c=this.ctx.createOscillator(),l=this.ctx.createGain();if(c.type=i,c.frequency.setValueAtTime(e,t+o),c.frequency.exponentialRampToValueAtTime(Math.max(n,20),t+o+r),l.gain.setValueAtTime(1e-4,t+o),l.gain.exponentialRampToValueAtTime(a,t+o+.012),l.gain.exponentialRampToValueAtTime(1e-4,t+o+r),s!==0&&typeof this.ctx.createStereoPanner==`function`){let e=this.ctx.createStereoPanner();e.pan.setValueAtTime(s,t+o),c.connect(l).connect(e).connect(this.sfx)}else c.connect(l).connect(this.sfx);c.start(t+o),c.stop(t+o+r+.05)};switch(e){case`pickup`:n(659.25,987.77,.09,`triangle`,.28,0,-.25),n(987.77,1318.51,.11,`triangle`,.26,.045,0),n(1318.51,1975.53,.16,`sine`,.24,.09,.25);break;case`jump`:n(330,660,.13,`triangle`,.16),n(660,990,.1,`sine`,.1,.03);break;case`land`:n(175,68,.1,`sine`,.24);break;case`hurt`:n(260,92,.26,`sawtooth`,.2,0,-.2),n(195,72,.28,`triangle`,.18,.04,.2);break;case`ui`:n(783.99,1046.5,.055,`triangle`,.16);break;case`dash`:n(587.33,240,.16,`sawtooth`,.12),n(880,1320,.12,`triangle`,.14,.02);break;case`boost`:n(349.23,880,.22,`sawtooth`,.16,0,-.25),n(523.25,1318.51,.24,`triangle`,.2,.03,.25),n(1046.5,2093,.2,`sine`,.16,.06,0);break;case`drift`:n(587.33,880,.1,`triangle`,.15,0,-.15),n(880,1174.66,.09,`sine`,.12,.02,.15);break;case`beep`:n(587.33,587.33,.13,`triangle`,.24),n(1174.66,1174.66,.08,`sine`,.1);break;case`go`:n(880,1174.66,.28,`triangle`,.28,0,-.2),n(1174.66,1760,.34,`triangle`,.28,.03,.2);break;case`lap`:[587.33,783.99,987.77,1174.66,1567.98].forEach((e,t)=>n(e,e*1.02,.15,`triangle`,.2,t*.06,(t-2)*.15));break;case`win`:[587.33,698.46,880,1174.66,1396.91,1760].forEach((e,t)=>n(e,e*1.01,.28,`triangle`,.24,t*.09,(t%2==0?-1:1)*.2));break;case`lose`:[440,392,349.23,293.66].forEach((e,t)=>n(e,e*.98,.34,`sine`,.22,t*.14))}}startMusic(){if(this.musicOn)return;this.musicOn=!0;let t=0,n=()=>{if(!this.musicOn)return;let r=this.finalLapMode?.175:.2,i=r*8,a=this.ctx.currentTime+.04,o=e[t%e.length],s=t%8>=4;o.chord.forEach((e,t)=>{let n=this.ctx.createOscillator(),r=this.ctx.createGain();n.type=t%2==0?`triangle`:`sine`,n.frequency.setValueAtTime(e,a),r.gain.setValueAtTime(1e-4,a),r.gain.linearRampToValueAtTime(.026,a+.09),r.gain.linearRampToValueAtTime(.018,a+i*.78),r.gain.linearRampToValueAtTime(1e-4,a+i+.05),n.connect(r).connect(this.music),n.start(a),n.stop(a+i+.06)});for(let e=0;e<8;e+=1){let t=a+e*r;(e===0||e===3||e===4)&&this.schedulePercussion(t,`kick`),(e===2||e===6)&&this.schedulePercussion(t,`snare`),this.schedulePercussion(t,`hat`),(s||this.finalLapMode)&&this.schedulePercussion(t+r*.5,`hat`);let n=e<4?o.bass[0]:o.bass[1],i=e%2==0?n:n*2,c=this.ctx.createOscillator(),l=this.ctx.createBiquadFilter(),u=this.ctx.createGain();c.type=`sawtooth`,c.frequency.setValueAtTime(i,t),l.type=`lowpass`,l.frequency.setValueAtTime(680,t),l.frequency.exponentialRampToValueAtTime(210,t+r*.8),u.gain.setValueAtTime(1e-4,t),u.gain.linearRampToValueAtTime(.055,t+.012),u.gain.exponentialRampToValueAtTime(1e-4,t+r*.88),c.connect(l).connect(u).connect(this.music),c.start(t),c.stop(t+r);let d=o.melody[e],f=this.ctx.createOscillator(),p=this.ctx.createGain();if(f.type=`triangle`,e%2==0?(f.frequency.setValueAtTime(d*.94,t),f.frequency.exponentialRampToValueAtTime(d,t+.025)):f.frequency.setValueAtTime(d,t),p.gain.setValueAtTime(1e-4,t),p.gain.linearRampToValueAtTime(.052,t+.014),p.gain.exponentialRampToValueAtTime(1e-4,t+r*.92),f.connect(p).connect(this.music),f.start(t),f.stop(t+r+.02),s||this.finalLapMode||e%2==1){let n=this.ctx.createOscillator(),i=this.ctx.createGain();n.type=`sine`,n.frequency.setValueAtTime(o.counter[e],t),i.gain.setValueAtTime(1e-4,t),i.gain.linearRampToValueAtTime(this.finalLapMode?.036:.024,t+.01),i.gain.exponentialRampToValueAtTime(1e-4,t+r*.75),n.connect(i).connect(this.music),n.start(t),n.stop(t+r)}}t+=1,this.musicTimer=window.setTimeout(n,Math.round(i*1e3))};n()}stopMusic(){this.musicOn=!1,clearTimeout(this.musicTimer)}updateEngine(e,t,n,r){if(this.ctx.state!==`running`)return;if(!r){this.engineGain&&this.engineGain.gain.setTargetAtTime(1e-4,this.ctx.currentTime,.08);return}(!this.engineOsc1||!this.engineOsc2||!this.engineFilter||!this.engineGain)&&(this.engineOsc1=this.ctx.createOscillator(),this.engineOsc2=this.ctx.createOscillator(),this.engineFilter=this.ctx.createBiquadFilter(),this.engineGain=this.ctx.createGain(),this.engineOsc1.type=`triangle`,this.engineOsc2.type=`sawtooth`,this.engineFilter.type=`lowpass`,this.engineFilter.Q.value=2.2,this.engineGain.gain.value=1e-4,this.engineOsc1.connect(this.engineFilter),this.engineOsc2.connect(this.engineFilter),this.engineFilter.connect(this.engineGain),this.engineGain.connect(this.sfx),this.engineOsc1.start(),this.engineOsc2.start());let i=this.ctx.currentTime,a=Math.max(0,Math.min(1.3,e)),o=72+a*135+(n?45:0)+t*14;this.engineOsc1.frequency.setTargetAtTime(o,i,.04),this.engineOsc2.frequency.setTargetAtTime(o*1.5,i,.04);let s=260+a*620+t*220+(n?520:0);this.engineFilter.frequency.setTargetAtTime(s,i,.05);let c=.025+Math.min(.045,a*.038)+(n?.018:0);this.engineGain.gain.setTargetAtTime(c,i,.06)}},n={"game.title":`LOLLY LAP`,"game.tagline":`Drift through Candy Valley and outsweeten seven critter rivals!`,"boot.loading":`Loading`,"boot.tap":`Press any key`,"menu.play":`Race Now`,"menu.continue":`Resume`,"menu.restart":`Restart Race`,"menu.settings":`Settings`,"menu.leaderboard":`Leaderboard`,"menu.garage":`Garage & Dyno`,"menu.quit":`Quit to Title`,"menu.back":`Back`,"menu.best":`Best {score}`,"prompt.select":`Select`,"prompt.back":`Back`,"prompt.camera":`360° Cam`,"prompt.freeCam":`Free Cam`,"hud.lap":`LAP`,"hud.score":`PTS`,"hud.speed":`km/h`,"hud.drift":`DRIFT`,"hud.boost":`LOLLY BOOST!`,"hud.itemEmpty":`No Item`,"hud.rolling":`Rolling...`,"hud.wrongWay":`WRONG WAY!`,"hud.finalLap":`FINAL LAP!`,"hud.lapBanner":`LAP {lap}! ({lap}/{total})`,"hud.go":`GO!`,"hud.freeCam":`FREE CAM 360°`,"hud.chaseCam":`CHASE CAM`,"place.1":`1st`,"place.2":`2nd`,"place.3":`3rd`,"place.4":`4th`,"place.5":`5th`,"place.6":`6th`,"place.7":`7th`,"place.8":`8th`,"item.boost":`Lolly Turbo`,"item.gumball":`Homing Gumball`,"item.puddle":`Caramel Puddle`,"item.shield":`Bubblegum Shield`,"menu.track":`Circuit`,"menu.laps":`Laps`,"menu.chooseTrack":`CHOOSE YOUR CIRCUIT`,"menu.chooseTrackSub":`Select a world, tune your kart, and join the race.`,"menu.lapCount":`LAPS`,"menu.comingSoon":`GARAGE STUDIO`,"map.candy":`Starlight Valley`,"map.candy.desc":`Pastel confectionery sweeps & macaron bridges`,"map.forest":`Emerald Pine Forest`,"map.forest.desc":`Lush mountain pines, wooden bridges & fireflies`,"map.beach":`Coral Coast`,"map.beach.desc":`Sunny ocean breeze, palm-lined sands & azure lagoons`,"map.frosthold":`Frosthold Citadel`,"map.frosthold.desc":`Glacier battlements, crystal spires & frosty blizzards`,"map.ember":`Emberglass Crater`,"map.ember.desc":`Obsidian switchbacks, lava seams & a smoldering volcano`,"map.skyway":`Celestial Skyway`,"map.skyway.desc":`Extra-long 1.7 km grand prix across starlit sky bridges`,"map.noel":`Winter Wonderland`,"map.noel.desc":`Snowy holiday wonderland with sparkling fairy lights & gift boxes`,"laps.2":`2 Laps`,"laps.3":`3 Laps`,"laps.5":`5 Laps`,"difficulty.easy":`Easy`,"difficulty.medium":`Medium`,"difficulty.hard":`Hard`,"difficulty.expert":`Expert`,"menu.selected":`Selected`,"laps.7":`7 Laps`,"settings.race":`Race`,"racer.luna":`Luna Axolotl`,"racer.pip":`Pip Penguin`,"racer.boba":`Boba Shiba`,"racer.sora":`Sora Dragon`,"racer.yuzu":`Yuzu Capybara`,"racer.pico":`Pico Koala`,"racer.coral":`Coral Bunny`,"racer.mochi":`Mochi Kitty`,"racer.biscuit":`Pip Penguin`,"racer.cocoa":`Boba Shiba`,"racer.taffy":`Sora Dragon`,"racer.pepper":`Yuzu Capybara`,"racer.waffle":`Pico Koala`,"hint.move.keyboard":`{keys} to steer and accelerate`,"hint.move.gamepad":`{stick} to steer and accelerate`,"hint.move.touch":`Drag the left pad to steer`,"hint.drift.keyboard":`Hold {key} while turning to drift-boost`,"hint.drift.gamepad":`Hold {key} while turning to drift-boost`,"hint.drift.touch":`Hold DRIFT while turning for a boost`,"hint.item.keyboard":`Press {key} or click to use candy power-ups`,"hint.item.gamepad":`Press {key} to use candy power-ups`,"hint.item.touch":`Tap ITEM to fire your candy power-up`,"pause.title":`Race Paused`,"settings.title":`Settings`,"settings.audio":`Audio`,"settings.music":`Music`,"settings.sfx":`Effects`,"settings.mute":`Mute all`,"settings.controls":`Controls`,"settings.sensitivity":`Look sensitivity`,"settings.invertY":`Invert vertical look`,"settings.display":`Display`,"settings.quality":`Graphics`,"settings.quality.low":`Low`,"settings.quality.medium":`Medium`,"settings.quality.high":`High`,"settings.reducedMotion":`Reduce camera shake`,"settings.language":`Language`,"settings.on":`On`,"settings.off":`Off`,"results.won":`Sweet Victory!`,"results.podium":`Podium Finish!`,"results.finished":`Race Complete!`,"results.place":`Finish Place`,"results.time":`Race Time`,"results.bestLap":`Best Lap`,"results.driftBonus":`Drift Boosts`,"results.hitBonus":`Power-up Hits`,"results.total":`Total Score`,"results.newBest":`New Record!`,"results.rank":`Rank #{rank}`,"results.name":`Driver name`,"results.save":`Save score`,"results.saved":`Saved`,"results.retry":`Race Again`,"results.title":`Title`,"leaderboard.title":`Rally Leaderboard & Telemetry`,"leaderboard.empty":`No races recorded yet. Take the pole!`,"leaderboard.score":`Score`,"leaderboard.time":`Time`,"touch.jump":`DRIFT`,"touch.dash":`ITEM`,"touch.pause":`Pause`,"credits.fonts":`Lolly Lap • 3D Kart Racing & Garage Dyno Studio`,"garage.title":`3D GARAGE DYNO & KART TUNING`,"garage.subtitle":`Customize transmission ratio, cornering grip, and mini-turbo boost response for your kart.`,"garage.preset.balanced":`Balanced Spec`,"garage.preset.speed":`Apex Top-Speed`,"garage.preset.drift":`Drift-Turbo Pro`,"garage.preset.grip":`Featherweight Grip`,"garage.stat.speed":`Top Speed`,"garage.stat.accel":`Acceleration`,"garage.stat.handling":`Corner Grip`,"garage.stat.drift":`Mini-Turbo`,"garage.reset":`Reset Factory Spec`,"garage.apply":`Apply & Return to Track`,"vip.button":`PRO PASS`,"vip.title":`LOLLY LAP CLUB — PRO RACING PASS`,"vip.subtitle":`Unlock all 7 championship circuits, all 8 critter drivers, Pro Garage Dyno setups, and endurance lap modes.`,"vip.demoNotice":`Includes a 7-Day Free Trial. Cancel anytime in your account settings.`,"vip.trialBadge":`7-DAY FREE TRIAL • CANCEL ANYTIME`,"vip.plan.monthly":`1 Month`,"vip.plan.monthly.price":`$4.99 / mo`,"vip.plan.monthly.sub":`7 days free, then $4.99 billed monthly`,"vip.plan.quarterly":`3 Months`,"vip.plan.quarterly.price":`$4.49 / mo`,"vip.plan.quarterly.sub":`7 days free, then $13.47 ($4.49 × 3) every 3 months`,"vip.plan.annual":`12 Months`,"vip.plan.annual.price":`$3.99 / mo`,"vip.plan.annual.sub":`7 days free, then $47.88 ($3.99 × 12) billed annually`,"vip.save10":`SAVE 10%`,"vip.bestValue":`BEST VALUE • SAVE 20%`,"vip.storesHeading":`INCLUDED IN PRO RACING PASS`,"vip.fullGameLock":`PRO PASS`,"vip.restore":`Restore Purchases`,"vip.continueDemo":`Back to Circuits`},r={"game.title":`LOLLY LAP`,"game.tagline":`漂移穿越糖果山谷，击败七位萌宠对手！`,"boot.loading":`加载中`,"boot.tap":`按任意键开始`,"menu.play":`开始比赛`,"menu.continue":`继续`,"menu.restart":`重新比赛`,"menu.settings":`设置`,"menu.leaderboard":`排行榜`,"menu.garage":`车库与调校`,"menu.quit":`返回标题`,"menu.back":`返回`,"menu.best":`最高分 {score}`,"prompt.select":`确认`,"prompt.back":`返回`,"prompt.camera":`360° 视角`,"prompt.freeCam":`自由视角`,"hud.lap":`圈数`,"hud.score":`积分`,"hud.speed":`公里/时`,"hud.drift":`漂移`,"hud.boost":`糖果加速！`,"hud.itemEmpty":`无道具`,"hud.rolling":`抽取中...`,"hud.wrongWay":`方向错误！`,"hud.finalLap":`最后一圈！`,"hud.lapBanner":`第 {lap} 圈！ ({lap}/{total})`,"hud.go":`出发！`,"hud.freeCam":`360° 自由视角`,"hud.chaseCam":`跟随追踪视角`,"place.1":`第1名`,"place.2":`第2名`,"place.3":`第3名`,"place.4":`第4名`,"place.5":`第5名`,"place.6":`第6名`,"place.7":`第7名`,"place.8":`第8名`,"item.boost":`糖果涡轮`,"item.gumball":`追踪泡泡糖`,"item.puddle":`焦糖水洼`,"item.shield":`泡泡护盾`,"menu.track":`赛道`,"menu.laps":`圈数`,"menu.chooseTrack":`选择赛道`,"menu.chooseTrackSub":`选择赛道，调校赛车并加入比赛。`,"menu.lapCount":`圈数`,"menu.comingSoon":`车库调校`,"map.candy":`星光糖果谷`,"map.candy.desc":`梦幻马卡龙与粉彩甜点赛道`,"map.forest":`翡翠松林赛道`,"map.forest.desc":`高山松林、木栈桥与流萤森林`,"map.beach":`珊瑚海岸`,"map.beach.desc":`海风椰林、白浪沙滩与蔚蓝泻湖`,"map.frosthold":`霜月城堡`,"map.frosthold.desc":`冰川要塞、晶体尖塔与冰封雪原`,"map.ember":`烬晶火山口`,"map.ember.desc":`黑曜石弯道、熔岩裂缝与炽热火山`,"map.skyway":`云端星河赛道`,"map.skyway.desc":`超长 1.7 公里星河云桥大奖赛`,"map.noel":`冰雪圣诞乐园`,"map.noel.desc":`白雪皑皑的圣诞主题赛道，缀满璀璨彩灯与节日礼物`,"laps.2":`2 圈`,"laps.3":`3 圈`,"laps.5":`5 圈`,"difficulty.easy":`简单`,"difficulty.medium":`中等`,"difficulty.hard":`困难`,"difficulty.expert":`专家`,"menu.selected":`已选择`,"laps.7":`7 圈`,"settings.race":`比赛设置`,"racer.luna":`露娜六角恐龙`,"racer.pip":`皮普小企鹅`,"racer.boba":`波霸柴犬`,"racer.sora":`空之小天龙`,"racer.yuzu":`柚子水豚`,"racer.pico":`皮克小考拉`,"racer.coral":`珊瑚小兔`,"racer.mochi":`麻薯小猫`,"racer.biscuit":`皮普小企鹅`,"racer.cocoa":`波霸柴犬`,"racer.taffy":`空之小天龙`,"racer.pepper":`柚子水豚`,"racer.waffle":`皮克小考拉`,"hint.move.keyboard":`{keys} 转向与加速`,"hint.move.gamepad":`{stick} 转向与加速`,"hint.move.touch":`拖动左侧摇杆转向`,"hint.drift.keyboard":`转弯时按住 {key} 蓄力漂移加速`,"hint.drift.gamepad":`转弯时按住 {key} 蓄力漂移加速`,"hint.drift.touch":`转弯时按住「漂移」蓄力加速`,"hint.item.keyboard":`按 {key} 或点击鼠标使用糖果道具`,"hint.item.gamepad":`按 {key} 使用糖果道具`,"hint.item.touch":`点按「道具」使用糖果道具`,"pause.title":`比赛暂停`,"settings.title":`设置`,"settings.audio":`声音`,"settings.music":`音乐`,"settings.sfx":`音效`,"settings.mute":`全部静音`,"settings.controls":`操作`,"settings.sensitivity":`视角灵敏度`,"settings.invertY":`反转垂直视角`,"settings.display":`画面`,"settings.quality":`画质`,"settings.quality.low":`低`,"settings.quality.medium":`中`,"settings.quality.high":`高`,"settings.reducedMotion":`减弱镜头震动`,"settings.language":`语言`,"settings.on":`开`,"settings.off":`关`,"results.won":`甜蜜胜利！`,"results.podium":`登上领奖台！`,"results.finished":`完成比赛！`,"results.place":`完赛名次`,"results.time":`比赛用时`,"results.bestLap":`最快单圈`,"results.driftBonus":`漂移加速奖励`,"results.hitBonus":`道具命中奖励`,"results.total":`总分`,"results.newBest":`新纪录！`,"results.rank":`第 {rank} 名`,"results.name":`车手名字`,"results.save":`保存成绩`,"results.saved":`已保存`,"results.retry":`再来一局`,"results.title":`标题画面`,"leaderboard.title":`拉力赛排行榜与遥测`,"leaderboard.empty":`还没有比赛记录，来创造首个纪录吧！`,"leaderboard.score":`得分`,"leaderboard.time":`用时`,"touch.jump":`漂移`,"touch.dash":`道具`,"touch.pause":`暂停`,"credits.fonts":`Lolly Lap • 3D 卡丁车与车库调校工坊`,"garage.title":`3D 车库测功机与卡丁车调校`,"garage.subtitle":`自定义变速传动比、弯道抓地力与漂移涡轮加速响应。`,"garage.preset.balanced":`均衡调校`,"garage.preset.speed":`极速冲刺`,"garage.preset.drift":`漂移专家`,"garage.preset.grip":`弯道抓地`,"garage.stat.speed":`最高速度`,"garage.stat.accel":`加速性能`,"garage.stat.handling":`弯道操控`,"garage.stat.drift":`漂移涡轮`,"garage.reset":`恢复原厂设置`,"garage.apply":`应用并返回赛道`,"vip.button":`PRO 通行证`,"vip.title":`LOLLY LAP 俱乐部 — 专业赛车通行证`,"vip.subtitle":`解锁全部 7 条锦标赛赛道、8 位萌宠车手、车库调校预设与耐力圈数模式。`,"vip.demoNotice":`包含 7 天免费试用，可随时在账户设置中取消。`,"vip.trialBadge":`7天免费试用 • 随时取消`,"vip.plan.monthly":`1 个月`,"vip.plan.monthly.price":`$4.99 / 月`,"vip.plan.monthly.sub":`前 7 天免费，之后每月 $4.99`,"vip.plan.quarterly":`3 个月`,"vip.plan.quarterly.price":`$4.49 / 月`,"vip.plan.quarterly.sub":`前 7 天免费，之后每 3 个月 $13.47 ($4.49 × 3)`,"vip.plan.annual":`12 个月`,"vip.plan.annual.price":`$3.99 / 月`,"vip.plan.annual.sub":`前 7 天免费，之后每年 $47.88 ($3.99 × 12)`,"vip.save10":`立省 10%`,"vip.bestValue":`最超值 • 立省 20%`,"vip.storesHeading":`专业赛车通行证权益`,"vip.fullGameLock":`专业版`,"vip.restore":`恢复购买`,"vip.continueDemo":`返回赛道`},i={"game.title":`LOLLY LAP`,"game.tagline":`Şeker Vadisi'nde drift at ve yedi sevimli rakibini geride bırak!`,"boot.loading":`Yükleniyor`,"boot.tap":`Başlamak için herhangi bir tuşa bas`,"menu.play":`Yarışa Başla`,"menu.continue":`Devam Et`,"menu.restart":`Yeniden Başlat`,"menu.settings":`Ayarlar`,"menu.leaderboard":`Skor Tablosu`,"menu.garage":`Garaj & Dyno`,"menu.quit":`Ana Menüye Dön`,"menu.back":`Geri`,"menu.best":`En İyi {score}`,"prompt.select":`Seç`,"prompt.back":`Geri`,"prompt.camera":`360° Kamera`,"prompt.freeCam":`Serbest Kamera`,"hud.lap":`TUR`,"hud.score":`PUAN`,"hud.speed":`km/s`,"hud.drift":`DRİFT`,"hud.boost":`LOLLY HIZI!`,"hud.itemEmpty":`Öğe Yok`,"hud.rolling":`Dönüyor...`,"hud.wrongWay":`TERS YÖN!`,"hud.finalLap":`SON TUR!`,"hud.lapBanner":`{lap}. TUR! ({lap}/{total})`,"hud.go":`BAŞLA!`,"hud.freeCam":`360° SERBEST KAMERA`,"hud.chaseCam":`TAKİP KAMERASI`,"place.1":`1.`,"place.2":`2.`,"place.3":`3.`,"place.4":`4.`,"place.5":`5.`,"place.6":`6.`,"place.7":`7.`,"place.8":`8.`,"item.boost":`Lolly Turbo`,"item.gumball":`Güdümlü Sakız`,"item.puddle":`Karamel Birikintisi`,"item.shield":`Sakız Kalkanı`,"menu.track":`Pist`,"menu.laps":`Tur`,"menu.chooseTrack":`PİSTİNİ SEÇ`,"menu.chooseTrackSub":`Bir dünya seç, aracını ayarla ve yarışa katıl.`,"menu.lapCount":`TUR SAYISI`,"menu.comingSoon":`GARAJ STÜDYOSU`,"map.candy":`Yıldız Işığı Vadisi`,"map.candy.desc":`Pastel şekerleme virajları ve makaron köprüler`,"map.forest":`Zümrüt Çam Ormanı`,"map.forest.desc":`Görkemli dağ çamları, ahşap köprüler ve ateş böcekleri`,"map.beach":`Mercan Sahili`,"map.beach.desc":`Güneşli okyanus esintisi, palmiyeler ve masmavi lagünler`,"map.frosthold":`Buz Hisarı`,"map.frosthold.desc":`Buzul surları, kristal kuleler ve dondurucu tipi`,"map.ember":`Köz Cam Krateri`,"map.ember.desc":`Obsidyen virajlar, lav damarları ve tüten bir yanardağ`,"map.skyway":`Semavi Gök Yolu`,"map.skyway.desc":`Yıldızlı gökyüzü köprülerinde 1.7 km'lik dev grand prix`,"map.noel":`Karlı Noel Diyarı`,"map.noel.desc":`Işıl ışıl peri ışıkları ve hediyelerle bezeli karlı harikalar diyarı`,"laps.2":`2 Tur`,"laps.3":`3 Tur`,"laps.5":`5 Tur`,"difficulty.easy":`Kolay`,"difficulty.medium":`Orta`,"difficulty.hard":`Zor`,"difficulty.expert":`Uzman`,"menu.selected":`Seçildi`,"laps.7":`7 Tur`,"settings.race":`Yarış`,"racer.luna":`Luna Aksolotl`,"racer.pip":`Pip Penguen`,"racer.boba":`Boba Shiba`,"racer.sora":`Sora Ejderha`,"racer.yuzu":`Yuzu Kapibara`,"racer.pico":`Pico Koala`,"racer.coral":`Mercan Tavşan`,"racer.mochi":`Mochi Kedi`,"racer.biscuit":`Pip Penguen`,"racer.cocoa":`Boba Shiba`,"racer.taffy":`Sora Ejderha`,"racer.pepper":`Yuzu Kapibara`,"racer.waffle":`Pico Koala`,"hint.move.keyboard":`{keys} ile yönlendir ve hızlan`,"hint.move.gamepad":`{stick} ile yönlendir ve hızlan`,"hint.move.touch":`Yönlendirmek için sol çubuğu sürükle`,"hint.drift.keyboard":`Drift takviyesi için dönerken {key} basılı tut`,"hint.drift.gamepad":`Drift takviyesi için dönerken {key} basılı tut`,"hint.drift.touch":`Drift takviyesi için dönerken DRIFT basılı tut`,"hint.item.keyboard":`Şeker güçlendiricilerini kullanmak için {key} bas veya tıkla`,"hint.item.gamepad":`Şeker güçlendiricilerini kullanmak için {key} bas`,"hint.item.touch":`Şeker gücünü ateşlemek için ITEM'e dokun`,"pause.title":`Yarış Duraklatıldı`,"settings.title":`Ayarlar`,"settings.audio":`Ses`,"settings.music":`Müzik`,"settings.sfx":`Efektler`,"settings.mute":`Tümünü Sessize Al`,"settings.controls":`Kontroller`,"settings.sensitivity":`Kamera hassasiyeti`,"settings.invertY":`Dikey bakışı ters çevir`,"settings.display":`Görüntü`,"settings.quality":`Grafik Kalitesi`,"settings.quality.low":`Düşük`,"settings.quality.medium":`Orta`,"settings.quality.high":`Yüksek`,"settings.reducedMotion":`Kamera sarsıntısını azalt`,"settings.language":`Dil / Language`,"settings.on":`Açık`,"settings.off":`Kapalı`,"results.won":`Tatlı Zafer!`,"results.podium":`Podyum Derecesi!`,"results.finished":`Yarış Tamamlandı!`,"results.place":`Bitiş Sırası`,"results.time":`Yarış Süresi`,"results.bestLap":`En İyi Tur`,"results.driftBonus":`Drift Hızlandırmaları`,"results.hitBonus":`Güçlendirici İsabetleri`,"results.total":`Toplam Puan`,"results.newBest":`Yeni Rekor!`,"results.rank":`Sıralama: #{rank}`,"results.name":`Sürücü Adı`,"results.save":`Skoru Kaydet`,"results.saved":`Kaydedildi`,"results.retry":`Tekrar Yarış`,"results.title":`Başlık`,"leaderboard.title":`Ralli Skor Tablosu & Telemetri`,"leaderboard.empty":`Henüz kayıtlı yarış yok. Birinci sırayı kap!`,"leaderboard.score":`Puan`,"leaderboard.time":`Süre`,"touch.jump":`DRİFT`,"touch.dash":`ÖĞE`,"touch.pause":`Duraklat`,"credits.fonts":`Lolly Lap • 3D Kart Yarışı & Garaj Dyno Stüdyosu`,"garage.title":`3B GARAJ DYNO & ARAÇ AYARLARI`,"garage.subtitle":`Şanzıman oranını, viraj tutuşunu ve mini-turbo tepkisini aracına göre özelleştir.`,"garage.preset.balanced":`Dengeli Ayar`,"garage.preset.speed":`Maksimum Hız`,"garage.preset.drift":`Drift-Turbo Pro`,"garage.preset.grip":`Keskin Viraj Tutuşu`,"garage.stat.speed":`Son Hız`,"garage.stat.accel":`İvmelenme`,"garage.stat.handling":`Viraj Tutuşu`,"garage.stat.drift":`Mini-Turbo`,"garage.reset":`Fabrika Ayarlarına Dön`,"garage.apply":`Uygula & Piste Dön`,"vip.button":`PRO PASS`,"vip.title":`LOLLY LAP CLUB — PRO YARIŞ PAKETİ`,"vip.subtitle":`Tüm 7 şampiyona pistini, 8 sevimli sürücüyü, Pro Garaj Dyno ayarlarını ve dayanıklılık turlarını açın.`,"vip.demoNotice":`7 Günlük Ücretsiz Deneme içerir. Hesap ayarlarından dilediğiniz zaman iptal edebilirsiniz.`,"vip.trialBadge":`7 GÜN ÜCRETSİZ DENEME • İSTEDİĞİN ZAMAN İPTAL ET`,"vip.plan.monthly":`Aylık (1 Ay)`,"vip.plan.monthly.price":`$4.99 / ay`,"vip.plan.monthly.sub":`7 gün ücretsiz, ardından ayda $4.99`,"vip.plan.quarterly":`3 Aylık`,"vip.plan.quarterly.price":`$4.49 / ay`,"vip.plan.quarterly.sub":`7 gün ücretsiz, ardından 3 ayda bir $13.47 ($4.49 × 3)`,"vip.plan.annual":`12 Aylık (Yıllık)`,"vip.plan.annual.price":`$3.99 / ay`,"vip.plan.annual.sub":`7 gün ücretsiz, ardından yılda $47.88 ($3.99 × 12)`,"vip.save10":`%10 İNDİRİM`,"vip.bestValue":`EN AVANTAJLI • %20 İNDİRİM`,"vip.storesHeading":`PRO YARIŞ PAKETİ İÇERİĞİ`,"vip.fullGameLock":`PRO PASS`,"vip.restore":`Satın Alımları Geri Yükle`,"vip.continueDemo":`Pistlere Dön`},a={en:{...n},"zh-CN":{...r},tr:{...i}};function o(e){let t=((e??[]).find(Boolean)??``).toLowerCase();return t.startsWith(`tr`)||t.endsWith(`-tr`)||t.endsWith(`_tr`)?`tr`:`en`}function s(e,t){return e===`en`||e===`zh-CN`||e===`tr`?e:o(t)}var c=class{locale;listeners=new Set;constructor(e){this.locale=e,document.documentElement.lang=e}t(e,t={}){return(a[this.locale]?.[e]??a.en[e]??e).replace(/\{(\w+)\}/g,(e,n)=>String(t[n]??`{${n}}`))}set(e){if(e!==this.locale){this.locale=e,document.documentElement.lang=e;for(let t of this.listeners)t(e)}}onChange(e){return this.listeners.add(e),()=>this.listeners.delete(e)}};Object.keys(n),Object.keys(r),Object.keys(i);var l={jump:[`Space`],sprint:[`ShiftLeft`,`ShiftRight`],dash:[`KeyF`,`KeyE`,`KeyJ`],pause:[`Escape`,`KeyP`],confirm:[`Enter`,`NumpadEnter`],back:[],interact:[`KeyR`],freeCam:[`KeyC`,`KeyV`],lookLeft:[`Digit1`,`Numpad1`,`Numpad4`],lookBack:[`Digit2`,`Numpad2`,`Numpad5`],lookRight:[`Digit3`,`Numpad3`,`Numpad6`]},u={up:[`KeyW`,`ArrowUp`],down:[`KeyS`,`ArrowDown`],left:[`KeyA`,`ArrowLeft`],right:[`KeyD`,`ArrowRight`]},d={jump:[0],sprint:[4,10],dash:[2,5,7],pause:[9],confirm:[0],back:[1],interact:[3],freeCam:[8],lookLeft:[],lookRight:[],lookBack:[]},f=class{move={x:0,y:0};look={x:0,y:0};method=`keyboard`;sensitivity=1;invertY=!1;keys=new Set;held_=new Set;pressed_=new Set;touchMove={x:0,y:0};touchButtons=new Set;padPrev=new Set;listeners=[];constructor(e){let t=(e,t,n,r)=>{e.addEventListener(t,n,r),this.listeners.push(()=>e.removeEventListener(t,n,r))};t(window,`keydown`,e=>{if(!e.repeat){this.keys.add(e.code),this.method=`keyboard`;for(let[t,n]of Object.entries(l))n.includes(e.code)&&this.pressed_.add(t);!e.target?.matches?.(`input, textarea`)&&(e.code===`Space`||e.code.startsWith(`Arrow`)||e.code.startsWith(`Digit`))&&e.preventDefault()}}),t(window,`keyup`,e=>this.keys.delete(e.code)),t(window,`blur`,()=>this.keys.clear()),t(window,`mousedown`,t=>{t.target===e&&t.button===0&&this.pressed_.add(`dash`),t.button===1&&this.pressed_.add(`lookBack`)}),t(window,`wheel`,t=>{if(t.target!==e||t.target?.matches?.(`input, textarea, select, .track-cards-shelf, .track-cards-shelf *, .track-grid-8, .track-grid-8 *`))return;let n=Math.sign(t.deltaY||t.deltaX);n!==0&&(this.look.x+=n*.42)},{passive:!0}),t(window,`contextmenu`,t=>{(t.target===e||t.target?.id===`game`)&&t.preventDefault()})}lockPointer(){}unlockPointer(){document.exitPointerLock?.()}setTouchMove(e,t){this.method=`touch`,this.touchMove.x=e,this.touchMove.y=t}addTouchLook(e,t){this.method=`touch`,this.look.x+=e*.006,this.look.y+=t*.006}setTouchButton(e,t){this.method=`touch`,t&&!this.touchButtons.has(e)&&this.pressed_.add(e),t?this.touchButtons.add(e):this.touchButtons.delete(e)}update(){let e=e=>e.some(e=>this.keys.has(e)),t=+!!e(u.right)-!!e(u.left),n=+!!e(u.up)-!!e(u.down);this.held_.clear();for(let[t,n]of Object.entries(l))e(n)&&this.held_.add(t);for(let e of this.touchButtons)this.held_.add(e);(this.touchMove.x!==0||this.touchMove.y!==0)&&(t=this.touchMove.x,n=this.touchMove.y);let r=navigator.getGamepads?.().find(e=>e&&e.connected);if(r){let e=e=>Math.abs(e)<.18?0:e,i=e(r.axes[0]??0),a=e(r.axes[1]??0),o=e(r.axes[2]??0),s=e(r.axes[3]??0);(i!==0||a!==0||o!==0||s!==0||r.buttons.some(e=>e.pressed))&&(this.method=`gamepad`),(i!==0||a!==0)&&(t=i,n=-a),this.look.x+=o*.045,this.look.y+=s*.045;let c=new Set;for(let[e,t]of Object.entries(d))t.some(e=>r.buttons[e]?.pressed)&&c.add(e);for(let e of c)this.held_.add(e),this.padPrev.has(e)||this.pressed_.add(e);this.padPrev=c}let i=Math.hypot(t,n);this.move.x=i>1?t/i:t,this.move.y=i>1?n/i:n}held(e){return this.held_.has(e)}pressed(e){return this.pressed_.has(e)}trigger(e){this.pressed_.add(e)}consume(e){return this.pressed_.delete(e)}takeLook(){let e={x:this.look.x*this.sensitivity,y:this.look.y*this.sensitivity*(this.invertY?-1:1)};return this.look.x=0,this.look.y=0,e}endFrame(){this.pressed_.clear()}dispose(){for(let e of this.listeners)e();this.listeners=[]}},p=class{callbacks;stepSeconds;accumulator=0;last=0;handle=0;running=!1;paused=!1;maxFrameSeconds=.25;constructor(e,t=60){this.callbacks=e,this.stepSeconds=1/t}start(){if(this.running)return;this.running=!0,this.last=performance.now();let e=t=>{if(!this.running)return;this.handle=requestAnimationFrame(e);let n=Math.max(0,Math.min((t-this.last)/1e3,this.maxFrameSeconds));if(this.last=t,!this.paused){this.accumulator+=n;try{for(;this.accumulator>=this.stepSeconds;)this.accumulator-=this.stepSeconds,this.callbacks.step(this.stepSeconds)}catch(e){throw this.accumulator=0,e}}this.callbacks.render(this.paused?1:this.accumulator/this.stepSeconds,n)};this.handle=requestAnimationFrame(e)}stop(){this.running=!1,cancelAnimationFrame(this.handle)}resetAccumulator(){this.accumulator=0,this.last=performance.now()}},m=`game3d.save`;function h(){return{version:1,locale:``,musicVolume:.7,sfxVolume:.8,muted:!1,sensitivity:1,invertY:!1,quality:`high`,reducedMotion:!1,tutorialDone:!1,playerName:`PLAYER`,map:`candy`,laps:3,leaderboard:[]}}var g=(e,t)=>typeof e==`number`&&Number.isFinite(e)?Math.min(1,Math.max(0,e)):t;function _(e){let t=h();if(!e)return t;let n;try{let r=JSON.parse(e);if(!r||typeof r!=`object`||Array.isArray(r))return t;n=r}catch{return t}if(n.version!==1)return t;let r=Array.isArray(n.leaderboard)?n.leaderboard:[];return{version:1,locale:n.locale===`en`||n.locale===`zh-CN`||n.locale===`tr`?n.locale:``,musicVolume:g(n.musicVolume,t.musicVolume),sfxVolume:g(n.sfxVolume,t.sfxVolume),muted:n.muted===!0,sensitivity:typeof n.sensitivity==`number`&&n.sensitivity>=.2&&n.sensitivity<=3?n.sensitivity:t.sensitivity,invertY:n.invertY===!0,quality:n.quality===`low`||n.quality===`medium`||n.quality===`high`?n.quality:t.quality,reducedMotion:n.reducedMotion===!0,tutorialDone:n.tutorialDone===!0,playerName:typeof n.playerName==`string`&&n.playerName.trim()?n.playerName.trim().slice(0,16):t.playerName,map:n.map===`forest`||n.map===`beach`||n.map===`frosthold`||n.map===`ember`||n.map===`skyway`||n.map===`noel`?n.map:`candy`,laps:n.laps===2||n.laps===3||n.laps===5||n.laps===7?n.laps:3,leaderboard:r.filter(e=>!!e&&typeof e==`object`&&typeof e.name==`string`&&Number.isFinite(e.score)).map(e=>({name:e.name.slice(0,16),score:Math.max(0,Math.floor(e.score)),seconds:Number.isFinite(e.seconds)?e.seconds:0,at:Number.isFinite(e.at)?e.at:0})).slice(0,10)}}function v(e,t){let n=[...e,t].sort((e,t)=>t.score-e.score||e.seconds-t.seconds||e.at-t.at).slice(0,10);return{board:n,rank:n.indexOf(t)}}var ee=class{storage;data;constructor(e=globalThis.localStorage){this.storage=e;let t=null;try{t=this.storage?.getItem(`game3d.save`)??null}catch{t=null}this.data=_(t)}update(e){this.data={...this.data,...e};try{this.storage?.setItem(m,JSON.stringify(this.data))}catch{}}};function y(e,t=!1){return!t||e===`candy`}function b(e,t=!1){return!t||e===0}function x(e,t=!1){return!t||e===3}var te=class{input;active;stickId=null;lookId=null;origin={x:0,y:0};last={x:0,y:0};stick;knob;constructor(e,t,n){this.input=t,this.active=n;let r=e.querySelector(`.touch`);this.stick=r.querySelector(`.touch-stick`),this.knob=this.stick.querySelector(`i`);let i=()=>document.body.classList.add(`has-touch`);matchMedia(`(pointer: coarse)`).matches&&i(),window.addEventListener(`touchstart`,i,{once:!0,passive:!0}),window.addEventListener(`pointerdown`,e=>{e.pointerType===`touch`&&(this.input.method=`touch`)},{capture:!0}),document.querySelector(`#game`).addEventListener(`pointerdown`,e=>{e.pointerType===`touch`&&this.active()&&(e.clientX<window.innerWidth*.45&&this.stickId===null?(this.stickId=e.pointerId,this.origin={x:e.clientX,y:e.clientY},this.stick.style.left=`${e.clientX}px`,this.stick.style.top=`${e.clientY}px`,this.stick.classList.add(`is-active`)):this.lookId===null&&(this.lookId=e.pointerId,this.last={x:e.clientX,y:e.clientY}))}),window.addEventListener(`pointermove`,e=>{if(e.pointerId===this.stickId){let t=e.clientX-this.origin.x,n=e.clientY-this.origin.y,r=Math.hypot(t,n);r>56&&(t=t/r*56,n=n/r*56),this.knob.style.transform=`translate(${t}px, ${n}px)`,this.input.setTouchMove(t/56,-n/56)}else e.pointerId===this.lookId&&(this.input.addTouchLook(e.clientX-this.last.x,e.clientY-this.last.y),this.last={x:e.clientX,y:e.clientY})});let a=e=>{e.pointerId===this.stickId&&(this.stickId=null,this.knob.style.transform=``,this.stick.classList.remove(`is-active`),this.input.setTouchMove(0,0)),e.pointerId===this.lookId&&(this.lookId=null)};window.addEventListener(`pointerup`,a),window.addEventListener(`pointercancel`,a);for(let e of r.querySelectorAll(`[data-touch]`)){let t=e.dataset.touch;e.addEventListener(`pointerdown`,n=>{n.pointerType===`touch`&&(n.preventDefault(),e.classList.add(`is-down`),this.input.setTouchButton(t,!0))});let n=()=>{e.classList.remove(`is-down`),this.input.setTouchButton(t,!1)};e.addEventListener(`pointerup`,n),e.addEventListener(`pointercancel`,n)}}},S={candy:{id:`candy`,nameKey:`map.candy`,descKey:`map.candy.desc`,length:`1.0 km`,difficultyKey:`difficulty.easy`,surface:`Pastel`,accentColor:`#ff5ca8`},forest:{id:`forest`,nameKey:`map.forest`,descKey:`map.forest.desc`,length:`1.2 km`,difficultyKey:`difficulty.medium`,surface:`Forest`,accentColor:`#2ecc71`},beach:{id:`beach`,nameKey:`map.beach`,descKey:`map.beach.desc`,length:`1.1 km`,difficultyKey:`difficulty.easy`,surface:`Coastal`,accentColor:`#ff9f43`},frosthold:{id:`frosthold`,nameKey:`map.frosthold`,descKey:`map.frosthold.desc`,length:`1.3 km`,difficultyKey:`difficulty.hard`,surface:`Glacier`,accentColor:`#54a0ff`},ember:{id:`ember`,nameKey:`map.ember`,descKey:`map.ember.desc`,length:`1.2 km`,difficultyKey:`difficulty.hard`,surface:`Volcanic`,accentColor:`#ff4757`},skyway:{id:`skyway`,nameKey:`map.skyway`,descKey:`map.skyway.desc`,length:`1.7 km`,difficultyKey:`difficulty.expert`,surface:`Cosmic`,accentColor:`#9b59b6`},noel:{id:`noel`,nameKey:`map.noel`,descKey:`map.noel.desc`,length:`1.4 km`,difficultyKey:`difficulty.medium`,surface:`Snow`,accentColor:`#2ed573`}},C={candy:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-candy" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#2d123b"/>
          <stop offset="55%" stop-color="#732b7d"/>
          <stop offset="100%" stop-color="#ff75a0"/>
        </linearGradient>
        <linearGradient id="hill-candy-1" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#ff9ec8"/>
          <stop offset="100%" stop-color="#e84393"/>
        </linearGradient>
        <linearGradient id="hill-candy-2" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#ffeaa7"/>
          <stop offset="100%" stop-color="#fdcb6e"/>
        </linearGradient>
        <linearGradient id="road-candy" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#4a2559"/>
          <stop offset="100%" stop-color="#2c1536"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-candy)"/>
      <!-- Stars & sparkles -->
      <circle cx="45" cy="32" r="1.5" fill="#fff" opacity=".8"/>
      <circle cx="112" cy="24" r="2" fill="#ffd0ea" opacity=".9"/>
      <circle cx="180" cy="40" r="1.2" fill="#fff" opacity=".7"/>
      <circle cx="260" cy="20" r="2.2" fill="#ffeaa7" opacity=".9"/>
      <circle cx="295" cy="55" r="1.5" fill="#fff" opacity=".8"/>
      <polygon points="112,18 114,24 120,24 115,28 117,34 112,30 107,34 109,28 104,24 110,24" fill="#ffd0ea" opacity=".8"/>
      <!-- Crescent moon -->
      <path d="M275 22 A 16 16 0 1 0 295 48 A 19 19 0 1 1 275 22 Z" fill="#ffeaa7" opacity=".92"/>
      <!-- Background candy hills -->
      <path d="M-20 180 Q 40 90 120 135 T 260 115 Q 300 125 340 180 Z" fill="url(#hill-candy-1)" opacity=".8"/>
      <path d="M60 180 Q 140 110 220 145 T 340 120 L 340 180 Z" fill="url(#hill-candy-2)" opacity=".7"/>
      <!-- Giant Swirl Lollipop -->
      <rect x="238" y="70" width="6" height="75" fill="#fff" rx="3"/>
      <circle cx="241" cy="68" r="28" fill="#ff7675"/>
      <circle cx="241" cy="68" r="22" fill="#fff"/>
      <circle cx="241" cy="68" r="16" fill="#e84393"/>
      <circle cx="241" cy="68" r="10" fill="#ffeaa7"/>
      <circle cx="241" cy="68" r="5" fill="#74b9ff"/>
      <!-- Macaron -->
      <ellipse cx="65" cy="115" rx="20" ry="8" fill="#fab1a0"/>
      <ellipse cx="65" cy="119" rx="20" ry="4" fill="#fff"/>
      <ellipse cx="65" cy="123" rx="20" ry="8" fill="#fab1a0"/>
      <!-- Winding racetrack -->
      <path d="M-10 180 Q 80 130 150 140 T 330 180 Z" fill="#e17055" opacity=".35"/>
      <path d="M-20 180 C 60 125, 120 155, 180 142 C 240 128, 290 150, 340 180 L 340 180 L -20 180 Z" fill="url(#road-candy)"/>
      <!-- Kerb & dashed line -->
      <path d="M-20 180 C 60 125, 120 155, 180 142 C 240 128, 290 150, 340 180" stroke="#ff4757" stroke-width="6" stroke-dasharray="14 10" fill="none"/>
      <path d="M-20 180 C 60 125, 120 155, 180 142 C 240 128, 290 150, 340 180" stroke="#ffeaa7" stroke-width="2.5" stroke-dasharray="12 12" fill="none" opacity=".85"/>
      <!-- Sprinkles -->
      <rect x="130" y="152" width="7" height="3" rx="1.5" fill="#55efc4" transform="rotate(25 130 152)"/>
      <rect x="165" y="160" width="7" height="3" rx="1.5" fill="#ffeaa7" transform="rotate(-35 165 160)"/>
      <rect x="210" y="155" width="7" height="3" rx="1.5" fill="#74b9ff" transform="rotate(15 210 155)"/>
    </svg>`,forest:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-forest" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#0d2127"/>
          <stop offset="60%" stop-color="#184a45"/>
          <stop offset="100%" stop-color="#ffb142"/>
        </linearGradient>
        <linearGradient id="mountain-forest" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#1f534d"/>
          <stop offset="100%" stop-color="#0a2320"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-forest)"/>
      <!-- Sun glow behind mountains -->
      <circle cx="160" cy="115" r="50" fill="#ffa502" opacity=".4" filter="blur(8px)"/>
      <!-- Distant Mountains -->
      <polygon points="20,135 90,65 160,135" fill="url(#mountain-forest)" opacity=".8"/>
      <polygon points="130,135 210,50 290,135" fill="url(#mountain-forest)" opacity=".7"/>
      <polygon points="230,135 285,75 340,135" fill="url(#mountain-forest)" opacity=".9"/>
      <!-- Tree silhouettes midground -->
      <path d="M-10 145 L15 110 L40 145 L65 115 L90 145 L115 105 L140 145 L175 110 L205 145 L245 105 L280 145 L310 115 L335 145 L335 180 L-10 180 Z" fill="#0b382c" opacity=".85"/>
      <!-- Detailed Foreground Pine Trees -->
      <g fill="#10ac84">
        <!-- Left Tree -->
        <polygon points="35,160 10,135 20,135 5,115 18,115 10,95 35,60 60,95 52,115 65,115 50,135 60,135"/>
        <rect x="31" y="155" width="8" height="20" fill="#593b21"/>
        <!-- Right Tree -->
        <polygon points="280,165 260,140 268,140 255,120 265,120 258,100 280,70 302,100 295,120 305,120 292,140 300,140"/>
        <rect x="276" y="160" width="8" height="18" fill="#593b21"/>
      </g>
      <!-- Rustic Wooden Bridge / Road -->
      <path d="M0 180 Q 110 135 160 138 T 320 180 Z" fill="#332418"/>
      <!-- Wooden planks & railings -->
      <path d="M60 156 L85 146 M105 146 L130 142 M150 142 L175 142 M195 142 L220 146 M240 148 L265 156" stroke="#b28956" stroke-width="3" stroke-linecap="round"/>
      <path d="M0 178 Q 110 133 160 136 T 320 178" stroke="#ffa502" stroke-width="2" stroke-dasharray="10 10" fill="none" opacity=".8"/>
      <!-- Glowing Fireflies -->
      <circle cx="120" cy="120" r="3" fill="#fffa65" opacity=".9"/>
      <circle cx="120" cy="120" r="7" fill="#fffa65" opacity=".35"/>
      <circle cx="190" cy="105" r="2.5" fill="#fffa65" opacity=".85"/>
      <circle cx="190" cy="105" r="6" fill="#fffa65" opacity=".3"/>
      <circle cx="235" cy="128" r="3" fill="#fffa65" opacity=".95"/>
      <circle cx="235" cy="128" r="8" fill="#fffa65" opacity=".4"/>
    </svg>`,beach:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-beach" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#ff5252"/>
          <stop offset="45%" stop-color="#ff793f"/>
          <stop offset="85%" stop-color="#ffda79"/>
          <stop offset="100%" stop-color="#ffeaa7"/>
        </linearGradient>
        <linearGradient id="sea-beach" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#227093"/>
          <stop offset="50%" stop-color="#00cec9"/>
          <stop offset="100%" stop-color="#81ecec"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-beach)"/>
      <!-- Tropical Sunset Sun -->
      <circle cx="205" cy="88" r="32" fill="#fff" opacity=".9"/>
      <circle cx="205" cy="88" r="44" fill="#fffa65" opacity=".4"/>
      <!-- Distant Island Silhouette -->
      <path d="M120 105 Q 150 96 175 105 Z" fill="#2c2c54" opacity=".5"/>
      <!-- Ocean water -->
      <path d="M0 102 L320 102 L320 145 C240 140, 160 148, 0 135 Z" fill="url(#sea-beach)"/>
      <!-- White surf waves -->
      <path d="M0 115 Q 80 110 160 116 T 320 114" stroke="#fff" stroke-width="2" fill="none" opacity=".8"/>
      <path d="M0 128 Q 90 124 180 130 T 320 127" stroke="#fff" stroke-width="2.5" fill="none" opacity=".7"/>
      <!-- Golden Beach Sand -->
      <path d="M0 132 C 100 130, 200 138, 320 130 L 320 180 L 0 180 Z" fill="#f7d794"/>
      <!-- Palm Tree Left -->
      <path d="M42 165 Q 65 120 70 85" stroke="#795548" stroke-width="7" stroke-linecap="round" fill="none"/>
      <!-- Palm Fronds -->
      <path d="M70 85 Q 40 75 25 88 M70 85 Q 55 60 40 68 M70 85 Q 80 55 95 62 M70 85 Q 98 75 110 92 M70 85 Q 75 70 88 78" stroke="#26de81" stroke-width="5" stroke-linecap="round" fill="none"/>
      <circle cx="68" cy="87" r="3" fill="#593b21"/>
      <circle cx="73" cy="88" r="3" fill="#593b21"/>
      <!-- Coastal Highway -->
      <path d="M-10 180 Q 90 150 160 152 T 330 180" stroke="#3d3d3d" stroke-width="36" fill="none"/>
      <path d="M-10 180 Q 90 150 160 152 T 330 180" stroke="#ff4757" stroke-width="38" stroke-dasharray="14 10" fill="none" opacity=".4"/>
      <path d="M-10 180 Q 90 150 160 152 T 330 180" stroke="#fff" stroke-width="3" stroke-dasharray="10 12" fill="none"/>
      <!-- Seagulls -->
      <path d="M125 52 Q 130 48 135 52 Q 140 48 145 52" stroke="#fff" stroke-width="1.8" fill="none" opacity=".85"/>
      <path d="M148 42 Q 152 39 156 42 Q 160 39 164 42" stroke="#fff" stroke-width="1.5" fill="none" opacity=".8"/>
    </svg>`,frosthold:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-frost" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#08101e"/>
          <stop offset="50%" stop-color="#0d2c4d"/>
          <stop offset="100%" stop-color="#225b82"/>
        </linearGradient>
        <linearGradient id="aurora" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#00d2d3" stop-opacity="0"/>
          <stop offset="40%" stop-color="#10ac84" stop-opacity=".75"/>
          <stop offset="70%" stop-color="#5f27cd" stop-opacity=".7"/>
          <stop offset="100%" stop-color="#48dbfb" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-frost)"/>
      <!-- Aurora Borealis ribbon -->
      <path d="M-20 60 Q 60 25 150 48 T 340 30 L 340 90 Q 240 100 150 80 T -20 100 Z" fill="url(#aurora)" filter="blur(6px)"/>
      <!-- Arctic Glacier Mountains -->
      <polygon points="-10,135 50,75 110,135" fill="#4b6584" opacity=".8"/>
      <polygon points="50,75 75,135 110,135" fill="#2d3f54" opacity=".9"/>
      <polygon points="210,135 270,68 330,135" fill="#4b6584" opacity=".8"/>
      <polygon points="270,68 295,135 330,135" fill="#2d3f54" opacity=".9"/>
      <!-- Frosthold Citadel Battlements -->
      <rect x="110" y="80" width="100" height="55" fill="#1e272e"/>
      <rect x="105" y="65" width="22" height="40" fill="#2f3542"/>
      <polygon points="105,65 116,42 127,65" fill="#00d2d3"/>
      <rect x="188" y="65" width="22" height="40" fill="#2f3542"/>
      <polygon points="188,65 199,42 210,65" fill="#00d2d3"/>
      <!-- Citadel Turrets & glowing blue window -->
      <rect x="135" y="74" width="8" height="8" fill="#1e272e"/>
      <rect x="150" y="74" width="8" height="8" fill="#1e272e"/>
      <rect x="165" y="74" width="8" height="8" fill="#1e272e"/>
      <rect x="177" y="74" width="8" height="8" fill="#1e272e"/>
      <rect x="150" y="96" width="20" height="30" rx="10" fill="#48dbfb" opacity=".9"/>
      <!-- Snowbanks & Ice Road -->
      <path d="M0 135 Q 160 120 320 135 L 320 180 L 0 180 Z" fill="#dff9fb"/>
      <path d="M-10 180 C 80 145, 140 155, 190 148 C 240 140, 280 158, 330 180" stroke="#48dbfb" stroke-width="32" stroke-linecap="round" fill="none" opacity=".85"/>
      <path d="M-10 180 C 80 145, 140 155, 190 148 C 240 140, 280 158, 330 180" stroke="#fff" stroke-width="3" stroke-dasharray="14 14" fill="none"/>
      <!-- Drift ice crystals -->
      <polygon points="40,155 45,148 50,155 45,162" fill="#c7ecee" opacity=".9"/>
      <polygon points="260,160 266,152 272,160 266,168" fill="#c7ecee" opacity=".9"/>
    </svg>`,ember:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-ember" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#190a12"/>
          <stop offset="55%" stop-color="#4d1217"/>
          <stop offset="100%" stop-color="#d63031"/>
        </linearGradient>
        <linearGradient id="lava" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#fffa65"/>
          <stop offset="40%" stop-color="#ff793f"/>
          <stop offset="100%" stop-color="#d63031"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-ember)"/>
      <!-- Ash smoke plumes -->
      <circle cx="160" cy="55" r="38" fill="#2d131a" opacity=".7" filter="blur(6px)"/>
      <circle cx="140" cy="40" r="28" fill="#1b080f" opacity=".8" filter="blur(5px)"/>
      <circle cx="185" cy="42" r="30" fill="#38101b" opacity=".75" filter="blur(5px)"/>
      <!-- Giant Volcano Caldera -->
      <polygon points="40,140 135,72 185,72 280,140" fill="#2d3436"/>
      <!-- Erupting Molten Lava Fall -->
      <polygon points="142,72 178,72 165,110 155,110" fill="url(#lava)"/>
      <path d="M160 70 Q 155 105 150 140 Q 140 160 120 180" stroke="url(#lava)" stroke-width="12" fill="none" opacity=".9"/>
      <path d="M160 70 Q 170 100 180 140" stroke="url(#lava)" stroke-width="7" fill="none" opacity=".85"/>
      <!-- Obsidian Crags foreground -->
      <polygon points="-10,180 30,130 80,180" fill="#1e272e"/>
      <polygon points="240,180 290,125 330,180" fill="#1e272e"/>
      <!-- Fiery Racetrack Bridge -->
      <path d="M-10 180 C 70 140, 130 150, 180 145 C 230 138, 270 155, 330 180" stroke="#1e272e" stroke-width="36" fill="none"/>
      <path d="M-10 180 C 70 140, 130 150, 180 145 C 230 138, 270 155, 330 180" stroke="#ff4757" stroke-width="38" stroke-dasharray="14 12" fill="none" opacity=".5"/>
      <path d="M-10 180 C 70 140, 130 150, 180 145 C 230 138, 270 155, 330 180" stroke="#fffa65" stroke-width="3" stroke-dasharray="10 14" fill="none"/>
      <!-- Flying Sparks / Embers -->
      <circle cx="150" cy="50" r="2" fill="#fffa65"/>
      <circle cx="170" cy="35" r="2.5" fill="#ff7675"/>
      <circle cx="130" cy="65" r="1.8" fill="#ffa801"/>
      <circle cx="195" cy="55" r="2" fill="#fffa65"/>
      <circle cx="105" cy="110" r="2" fill="#fffa65"/>
      <circle cx="215" cy="120" r="2" fill="#ff7675"/>
    </svg>`,skyway:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-space" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#04010d"/>
          <stop offset="50%" stop-color="#13092c"/>
          <stop offset="100%" stop-color="#2a0845"/>
        </linearGradient>
        <linearGradient id="rainbow-ribbon" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#00f2fe"/>
          <stop offset="35%" stop-color="#4facfe"/>
          <stop offset="70%" stop-color="#f355da"/>
          <stop offset="100%" stop-color="#ffeaa7"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-space)"/>
      <!-- Cosmic Stars -->
      <circle cx="30" cy="20" r="1.2" fill="#fff" opacity=".8"/>
      <circle cx="85" cy="45" r="1.8" fill="#ffeaa7" opacity=".9"/>
      <circle cx="140" cy="15" r="1.5" fill="#fff" opacity=".7"/>
      <circle cx="210" cy="38" r="2" fill="#70a1ff" opacity=".9"/>
      <circle cx="280" cy="22" r="1.3" fill="#fff" opacity=".8"/>
      <circle cx="305" cy="65" r="1.7" fill="#ff79cd" opacity=".8"/>
      <!-- Ringed Planet -->
      <circle cx="75" cy="65" r="22" fill="#6c5ce7"/>
      <ellipse cx="75" cy="65" rx="38" ry="8" fill="none" stroke="#a29bfe" stroke-width="3" transform="rotate(-20 75 65)" opacity=".85"/>
      <!-- Cosmic Nebula glow -->
      <circle cx="240" cy="80" r="60" fill="#9b59b6" opacity=".25" filter="blur(14px)"/>
      <!-- Floating Neon Celestial Track Ribbon -->
      <path d="M-20 170 C 60 110, 130 160, 200 130 C 260 105, 300 140, 340 160" stroke="url(#rainbow-ribbon)" stroke-width="26" stroke-linecap="round" fill="none" opacity=".95"/>
      <path d="M-20 170 C 60 110, 130 160, 200 130 C 260 105, 300 140, 340 160" stroke="#fff" stroke-width="3" stroke-dasharray="14 12" fill="none"/>
      <!-- Glowing Edge Guardrails -->
      <path d="M-20 182 C 60 122, 130 172, 200 142 C 260 117, 300 152, 340 172" stroke="#00f2fe" stroke-width="2.5" fill="none" opacity=".85"/>
      <path d="M-20 158 C 60 98, 130 148, 200 118 C 260 93, 300 128, 340 148" stroke="#f355da" stroke-width="2.5" fill="none" opacity=".85"/>
      <!-- Neon Speed Arrows on track -->
      <polygon points="120,132 130,137 120,142 124,137" fill="#fff"/>
      <polygon points="145,134 155,137 145,140 148,137" fill="#fff"/>
    </svg>`,noel:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-noel" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#180e22"/>
          <stop offset="55%" stop-color="#2d193d"/>
          <stop offset="100%" stop-color="#542866"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-noel)"/>
      <!-- Falling Snowflakes -->
      <circle cx="35" cy="25" r="1.8" fill="#fff" opacity=".9"/>
      <circle cx="85" cy="45" r="2.2" fill="#fff" opacity=".8"/>
      <circle cx="130" cy="20" r="1.5" fill="#fff" opacity=".7"/>
      <circle cx="175" cy="50" r="2.5" fill="#fff" opacity=".85"/>
      <circle cx="225" cy="30" r="1.8" fill="#fff" opacity=".8"/>
      <circle cx="270" cy="40" r="2.2" fill="#fff" opacity=".9"/>
      <circle cx="305" cy="22" r="1.6" fill="#fff" opacity=".75"/>
      <!-- Distant Snowy Alps -->
      <polygon points="-20,135 45,72 110,135" fill="#341e45" opacity=".9"/>
      <polygon points="45,72 75,135 110,135" fill="#231330"/>
      <polygon points="200,135 260,65 320,135" fill="#341e45" opacity=".9"/>
      <polygon points="260,65 290,135 320,135" fill="#231330"/>
      <!-- Snow Ground Plane -->
      <path d="M-10 130 Q 150 118 330 130 L 330 180 L -10 180 Z" fill="#ecf0f1"/>
      <!-- Gingerbread Cottage in Distance -->
      <rect x="75" y="98" width="38" height="28" fill="#795548"/>
      <polygon points="68,98 94,76 120,98" fill="#fff"/>
      <rect x="88" y="108" width="12" height="18" fill="#ffeaa7"/>
      <!-- Giant Grand Christmas Tree -->
      <g>
        <rect x="238" y="140" width="8" height="20" fill="#593b21"/>
        <polygon points="242,55 268,90 258,90 278,120 266,120 286,145 198,145 218,120 206,120 226,90 216,90" fill="#10ac84"/>
        <!-- Golden Star on top -->
        <polygon points="242,46 244,52 250,52 245,56 247,62 242,58 237,62 239,56 234,52 240,52" fill="#ffd32a"/>
        <!-- Colorful Baubles -->
        <circle cx="230" cy="85" r="3.2" fill="#ff4757"/>
        <circle cx="252" cy="88" r="3" fill="#ffd32a"/>
        <circle cx="225" cy="112" r="3.5" fill="#00d2d3"/>
        <circle cx="245" cy="110" r="3.2" fill="#ff4757"/>
        <circle cx="262" cy="114" r="3.5" fill="#ffd32a"/>
        <circle cx="215" cy="135" r="4" fill="#ff9ff3"/>
        <circle cx="238" cy="132" r="4" fill="#ffd32a"/>
        <circle cx="260" cy="136" r="3.8" fill="#00d2d3"/>
      </g>
      <!-- Snowman Left -->
      <circle cx="52" cy="142" r="14" fill="#fff"/>
      <circle cx="52" cy="122" r="10" fill="#fff"/>
      <circle cx="52" cy="107" r="7.5" fill="#fff"/>
      <!-- Snowman hat & carrot -->
      <rect x="46" y="96" width="12" height="6" fill="#2d3436"/>
      <rect x="48" y="90" width="8" height="8" fill="#ff4757"/>
      <polygon points="52,108 60,109 52,111" fill="#ff793f"/>
      <!-- Wrapped Gifts -->
      <rect x="188" y="148" width="16" height="16" rx="2" fill="#ff4757"/>
      <rect x="195" y="148" width="3" height="16" fill="#ffd32a"/>
      <rect x="188" y="155" width="16" height="3" fill="#ffd32a"/>
      <!-- Snowy Winding Road -->
      <path d="M-10 180 C 70 145, 130 152, 175 146 C 220 140, 270 155, 330 180" stroke="#3d3d3d" stroke-width="36" fill="none"/>
      <path d="M-10 180 C 70 145, 130 152, 175 146 C 220 140, 270 155, 330 180" stroke="#ff4757" stroke-width="38" stroke-dasharray="14 10" fill="none" opacity=".5"/>
      <path d="M-10 180 C 70 145, 130 152, 175 146 C 220 140, 270 155, 330 180" stroke="#fff" stroke-width="3" stroke-dasharray="10 12" fill="none"/>
    </svg>`,soon:`
    <svg viewBox="0 0 320 180" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" class="track-svg">
      <defs>
        <linearGradient id="sky-soon" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#111a36"/>
          <stop offset="55%" stop-color="#221742"/>
          <stop offset="100%" stop-color="#3a164c"/>
        </linearGradient>
        <linearGradient id="dyno-arc" x1="0" y1="1" x2="1" y2="0">
          <stop offset="0%" stop-color="#7ef9ff"/>
          <stop offset="50%" stop-color="#ffe066"/>
          <stop offset="100%" stop-color="#ff3388"/>
        </linearGradient>
      </defs>
      <rect width="320" height="180" fill="url(#sky-soon)"/>
      <!-- Neon Dyno Grid -->
      <path d="M0 145 H320 M0 115 H320 M0 85 H320 M64 50 V180 M128 50 V180 M192 50 V180 M256 50 V180" stroke="#7ef9ff" stroke-width="1" opacity=".14"/>
      <!-- Glowing Telemetry Curve -->
      <path d="M20 155 C 85 150, 125 95, 185 82 C 235 72, 265 48, 305 38" stroke="url(#dyno-arc)" stroke-width="4.5" fill="none" stroke-linecap="round"/>
      <!-- Tachometer Dial Center -->
      <circle cx="160" cy="96" r="46" fill="#130f26" opacity=".82" stroke="#7ef9ff" stroke-width="2" stroke-opacity=".4"/>
      <path d="M126 120 A 42 42 0 1 1 194 120" stroke="url(#dyno-arc)" stroke-width="7" fill="none" stroke-linecap="round"/>
      <!-- Tachometer Needle -->
      <line x1="160" y1="96" x2="186" y2="74" stroke="#ff3388" stroke-width="4" stroke-linecap="round"/>
      <circle cx="160" cy="96" r="6" fill="#ffe066"/>
      <text x="160" y="132" text-anchor="middle" font-family="system-ui, sans-serif" font-weight="900" font-size="14" fill="#7ef9ff" letter-spacing="2">DYNO PRO</text>
    </svg>`},w={race:{laps:3,countdown:3.6,aiSkill:1,finishGrace:8},kart:{radius:1.15,maxSpeed:36,acceleration:24,brakeDecel:50,reverseSpeed:9,drag:6,turnRate:2,highSpeedTurn:.6,offroadFactor:.5,shoulder:6,boostSpeed:50,boostAccel:60},drift:{minSpeed:.45,base:1.35,range:.6,slip:.42,tier1:.9,tier2:1.9,tier3:3,boost1:.8,boost2:1.3,boost3:1.9},items:{respawn:4,pickupRadius:2.3,rollTime:.9,boostTime:2.2,gumballSpeed:64,gumballLife:6,puddleLife:14,puddleRadius:2.8,shieldTime:9,pulseRadius:16,spinTime:1.15,invulnerable:2},score:{hit:50,driftBoost:25},camera:{distance:7.6,height:3.6,follow:7,fov:68},ai:{lateral:30}},T=structuredClone(w),E=[`boost`,`gumball`,`puddle`,`shield`,`pulse`],D=[1e3,800,650,500,350,200,120,60];function ne(e,t,n=T){let r=t===void 0?n.race.laps:t;return{unranked:!1,phase:`countdown`,countdown:n.race.countdown,clock:0,laps:Math.max(1,Math.round(r)),lap:1,place:e,racers:e,lapTimes:[],lapStart:0,bestLap:0,driftBoosts:0,hits:0,finishTime:0,score:0}}function re(e,t){if(e.phase===`countdown`){let n=e.countdown-t;return n>0?{...e,countdown:n}:{...e,phase:`racing`,countdown:0,clock:-n}}return{...e,clock:e.clock+t}}function O(e){if(e.phase===`countdown`)return e;let t=e.clock-e.lapStart;return{...e,lapTimes:[...e.lapTimes,t],lapStart:e.clock,bestLap:e.bestLap===0?t:Math.min(e.bestLap,t),lap:Math.min(e.laps,e.lap+1)}}function k(e,t){return e.place===t?e:{...e,place:t}}function A(e){return e.phase===`racing`?{...e,driftBoosts:e.driftBoosts+1}:e}function j(e){return e.phase===`racing`?{...e,hits:e.hits+1}:e}function M(e,t,n,r=T){return(D[e-1]??0)+t*r.score.driftBoost+n*r.score.hit}function N(e,t){return e.phase===`racing`?{...O({...e,lap:e.laps}),phase:`finished`,place:t,finishTime:e.clock,score:M(t,e.driftBoosts,e.hits)}:e}function ie(e){return[...e].sort((e,t)=>{let n=e.finishTime!==null,r=t.finishTime!==null;return n===r?n&&r?e.finishTime-t.finishTime||e.id-t.id:t.dist-e.dist||e.id-t.id:n?-1:1}).map(e=>e.id)}function ae(e){return e===1?3:e<=3?2:+(e===4)}var P={boost:[3,4],gumball:[4,3],puddle:[4,1],shield:[3,2],pulse:[0,3]};function oe(e,t){let n=t<=1?0:Math.min(1,Math.max(0,e/(t-1))),r={};for(let e of E)r[e]=P[e][0]+(P[e][1]-P[e][0])*n;return r}function se(e,t,n){let r=oe(e,t),i=E.reduce((e,t)=>e+r[t],0),a=Math.min(.999999,Math.max(0,n))*i;for(let e of E)if(a-=r[e],a<0&&r[e]>0)return e;return`boost`}function F(e){let t=Math.floor(Math.max(0,e)*100),n=Math.floor(t/6e3),r=Math.floor(t%6e3/100);return`${n}:${String(r).padStart(2,`0`)}.${String(t%100).padStart(2,`0`)}`}var I=[];function L(e,t,n,r,i,a,o,s){let c=T[e],l=w[e],u=e===`kart`||e===`drift`?`Handling`:e===`items`?`Items`:e===`camera`?`Camera`:`Race`,d=s===`drift`?`Applies when the next drift boost fires.`:s===`item`?`Applies when the next power-up is activated.`:s===`run`?`Applies when a new race starts.`:`Updates this preview immediately.`;I.push({control:Object.freeze({id:`${e}.${t}`,type:`number`,category:u,label:n,description:d,unit:o,default:l[t],min:r,max:i,step:a,applyMode:s===`run`?`NEXT_RUN`:s?`NEXT_ACTION`:`LIVE`,integrity:e===`camera`?`COSMETIC`:`GAMEPLAY`}),boundary:s,read:()=>c[t],write:e=>{c[t]=e}})}L(`kart`,`maxSpeed`,`Top speed`,16,60,1,`m/s`),L(`kart`,`boostSpeed`,`Boost top speed`,24,80,1,`m/s`),L(`kart`,`acceleration`,`Acceleration`,8,60,1,`m/s²`),L(`kart`,`turnRate`,`Steering rate`,.8,3.6,.1,`rad/s`),L(`drift`,`boost1`,`Mini-turbo boost`,.3,2,.1,`s`,`drift`),L(`items`,`boostTime`,`Lolly Turbo boost`,.8,5,.2,`s`,`item`),L(`camera`,`fov`,`Field of view`,40,100,1,`°`),L(`camera`,`distance`,`Camera distance`,4,14,.2,`m`),L(`camera`,`follow`,`Camera follow speed`,2,20,1,``),L(`race`,`laps`,`Race laps`,1,7,1,``,`run`),L(`race`,`aiSkill`,`AI rival pace`,.6,1.3,.05,`×`,`run`);var R=new Map(I.map(e=>[e.control.id,e])),z=Object.fromEntries(I.map(({control:e})=>[e.id,e.default])),ce=e=>e[`kart.maxSpeed`]<=e[`kart.boostSpeed`],B=!1,V=()=>I.some(e=>e.control.integrity===`GAMEPLAY`&&e.read()!==e.control.default),H={get unranked(){return B},controls:Object.freeze(I.map(e=>e.control)),read(){return{requested:{...z},active:Object.fromEntries(I.map(e=>[e.control.id,e.read()]))}},apply(e){if(!e||typeof e!=`object`||Array.isArray(e))throw Error(`Invalid patch`);let t=Object.entries(e);if(t.length>I.length)throw Error(`Invalid patch`);for(let[e,n]of t){let t=R.get(e)?.control;if(!t||typeof n!=`number`||!Number.isFinite(n)||n<t.min||n>t.max)throw Error(`Invalid value`);let r=(n-t.min)/t.step;if(n!==t.default&&Math.abs(r-Math.round(r))>1e-7)throw Error(`Invalid increment`)}let n={...z,...e},r=this.read().active;for(let[e,n]of t)R.get(e).control.applyMode===`LIVE`&&(r[e]=n);if(!ce(n)||!ce(r))throw Error(`Top speed must not exceed boost top speed`);z=n;for(let[e,n]of t){let t=R.get(e);t.control.applyMode===`LIVE`&&t.write(n)}B||=V()},activate(e){for(let t of I)t.boundary===e&&t.write(z[t.control.id]);B=e===`run`?V():B||V()}},le=[{x:0,z:0,y:0,w:26},{x:72,z:-5,y:0,w:26},{x:144,z:-2,y:1.2,w:25},{x:205,z:19,y:3.4,w:24},{x:244,z:65,y:4.6,w:23},{x:240,z:122,y:4.5,w:23},{x:202,z:162,y:3.2,w:22},{x:150,z:166,y:2.2,w:22},{x:108,z:132,y:1.2,w:21},{x:72,z:158,y:1.4,w:21},{x:36,z:200,y:2.4,w:21},{x:-10,z:195,y:3.2,w:22},{x:-56,z:222,y:3.5,w:24},{x:-108,z:194,y:3,w:24},{x:-132,z:130,y:2,w:23},{x:-108,z:68,y:1,w:23},{x:-56,z:20,y:0,w:25}],ue=Math.PI*2,de=e=>{let t=(e+Math.PI)%ue;return t<0&&(t+=ue),t-Math.PI};function U(e,t,n,r,i){return .5*(2*t+(-e+n)*i+(2*e-5*t+4*n-r)*i*i+(-e+3*t-3*n+r)*i*i*i)}var W=class{samples;length;count;spacing;verge;constructor(e=le,t=2,n=6){this.verge=n;let r=e.length,i=[];for(let t=0;t<r;t+=1){let n=e[(t-1+r)%r],a=e[t],o=e[(t+1)%r],s=e[(t+2)%r];for(let e=0;e<48;e+=1){let t=e/48;i.push({x:U(n.x,a.x,o.x,s.x,t),z:U(n.z,a.z,o.z,s.z,t),y:U(n.y,a.y,o.y,s.y,t),w:U(n.w,a.w,o.w,s.w,t)})}}let a=[0];for(let e=1;e<=i.length;e+=1){let t=i[e-1],n=i[e%i.length];a.push(a[e-1]+Math.hypot(n.x-t.x,n.z-t.z))}let o=a[a.length-1];this.count=Math.round(o/t),this.spacing=o/this.count,this.length=o;let s=[],c=0;for(let e=0;e<this.count;e+=1){let t=e*this.spacing;for(;c<i.length-1&&a[c+1]<t;)c+=1;let n=i[c],r=i[(c+1)%i.length],o=(t-a[c])/Math.max(1e-6,a[c+1]-a[c]);s.push({x:n.x+(r.x-n.x)*o,z:n.z+(r.z-n.z)*o,y:n.y+(r.y-n.y)*o,w:n.w+(r.w-n.w)*o,d:t})}let l=this.count,u=[],d=s.map((e,t)=>{let n=s[(t-1+l)%l],r=s[(t+1)%l],i=Math.hypot(r.x-n.x,r.z-n.z)||1,a=(r.x-n.x)/i,o=(r.z-n.z)/i;return u.push(Math.atan2(a,o)),{x:e.x,y:e.y,z:e.z,tx:a,tz:o,nx:-o,nz:a,w:e.w,d:e.d,k:0,slope:(r.y-n.y)/(2*this.spacing)}}),f=u.map((e,t)=>-de(u[(t+1)%l]-u[(t-1+l)%l])/(2*this.spacing));for(let e=0;e<l;e+=1){let t=0;for(let n=-4;n<=4;n+=1)t+=f[(e+n+l)%l];d[e].k=t/9}this.samples=d}wrap(e){return(e%this.count+this.count)%this.count}limit(e){return this.samples[this.wrap(e)].w/2+this.verge}locate(e,t,n=-1){let r=this.count,i=-1,a=1/0;if(n>=0)for(let o=-24;o<=24;o+=1){let s=(n+o+r)%r,c=this.samples[s],l=(c.x-e)**2+(c.z-t)**2;l<a&&(a=l,i=s)}if(i<0||a>3600){a=1/0;for(let n=0;n<r;n+=1){let r=this.samples[n],o=(r.x-e)**2+(r.z-t)**2;o<a&&(a=o,i=n)}}let o=this.samples[i],s=e-o.x,c=t-o.z,l=s*o.tx+c*o.tz,u=s*o.nx+c*o.nz,d=((o.d+l)%this.length+this.length)%this.length;return{index:i,along:l,lateral:u,y:o.y+o.slope*l,lapDist:d}}at(e,t=0){let n=(e/this.spacing%this.count+this.count)%this.count,r=Math.floor(n),i=n-r,a=this.samples[r],o=this.samples[(r+1)%this.count],s=a.tx+(o.tx-a.tx)*i,c=a.tz+(o.tz-a.tz)*i,l=Math.hypot(s,c)||1,u=-c/l,d=s/l;return{x:a.x+(o.x-a.x)*i+u*t,y:a.y+(o.y-a.y)*i,z:a.z+(o.z-a.z)*i+d*t,heading:Math.atan2(s,c),w:a.w+(o.w-a.w)*i,k:a.k+(o.k-a.k)*i}}peakCurvature(e,t){let n=Math.max(1,Math.round(t/this.spacing)),r=Math.floor(e/this.spacing),i=0,a=0;for(let e=0;e<=n;e+=1){let t=this.samples[this.wrap(r+e)].k;Math.abs(t)>i&&(i=Math.abs(t),a=t)}return{abs:i,signed:a}}gridSlot(e){let t=Math.floor(e/2),n=e%2==0;return{dist:7+t*9+(n?0:4),lateral:n?-5:5}}},fe=[78,212,355,498,640,778],G=[{d:138,lateral:-4.6},{d:288,lateral:4.6},{d:432,lateral:0},{d:568,lateral:-4.8},{d:710,lateral:4.2},{d:842,lateral:0}],pe=[{x:0,z:0,y:0,w:26},{x:74,z:-6,y:.4,w:26},{x:148,z:-8,y:1.6,w:25},{x:212,z:18,y:4,w:24},{x:252,z:68,y:5.8,w:23},{x:246,z:128,y:5.4,w:23},{x:204,z:174,y:4.2,w:22},{x:148,z:178,y:3,w:22},{x:102,z:142,y:1.8,w:21},{x:60,z:168,y:1.6,w:21},{x:22,z:210,y:2.6,w:22},{x:-24,z:204,y:3.2,w:23},{x:-72,z:228,y:3.5,w:24},{x:-120,z:196,y:2.8,w:24},{x:-142,z:128,y:1.8,w:23},{x:-114,z:64,y:.8,w:23},{x:-58,z:18,y:0,w:25}],me=[82,224,368,512,658,804],he=[{d:144,lateral:-4.5},{d:298,lateral:4.5},{d:446,lateral:0},{d:586,lateral:-4.6},{d:732,lateral:4.4},{d:868,lateral:0}],ge=[{x:0,z:0,y:0,w:26},{x:74,z:-8,y:.2,w:26},{x:150,z:-2,y:.8,w:25},{x:205,z:26,y:1.6,w:24},{x:222,z:84,y:2.5,w:23},{x:184,z:130,y:1.6,w:22},{x:124,z:150,y:.7,w:22},{x:72,z:126,y:.2,w:21},{x:32,z:154,y:.9,w:21},{x:-20,z:180,y:1.8,w:22},{x:-84,z:156,y:1.3,w:23},{x:-126,z:102,y:.4,w:23},{x:-120,z:48,y:.1,w:24},{x:-58,z:12,y:0,w:25}],_e=[82,224,368,512,658,804],ve=[{d:140,lateral:-4.5},{d:296,lateral:4.5},{d:444,lateral:0},{d:584,lateral:-4.6},{d:730,lateral:4.4},{d:866,lateral:0}],ye=[{x:0,z:0,y:0,w:26},{x:84,z:-4,y:.8,w:26},{x:162,z:-12,y:2.6,w:25},{x:226,z:20,y:5.2,w:24},{x:260,z:80,y:7.4,w:23},{x:232,z:142,y:6,w:22},{x:172,z:178,y:3.6,w:22},{x:106,z:158,y:2,w:21},{x:48,z:210,y:4.6,w:22},{x:-18,z:218,y:6.2,w:23},{x:-82,z:188,y:4,w:24},{x:-140,z:124,y:1.8,w:23},{x:-118,z:56,y:.7,w:24},{x:-56,z:12,y:0,w:25}],be=[82,228,376,522,670,812],xe=[{d:142,lateral:-4.6},{d:294,lateral:4.6},{d:446,lateral:0},{d:594,lateral:-4.7},{d:742,lateral:4.4},{d:858,lateral:0}],Se=[{x:0,z:0,y:0,w:26},{x:82,z:4,y:.7,w:26},{x:156,z:30,y:2.4,w:25},{x:208,z:76,y:4.6,w:24},{x:200,z:132,y:5.8,w:23},{x:140,z:162,y:3.8,w:22},{x:70,z:144,y:1.6,w:21},{x:18,z:184,y:3.1,w:22},{x:-52,z:222,y:5.4,w:23},{x:-120,z:192,y:3.6,w:24},{x:-142,z:124,y:1.4,w:23},{x:-102,z:60,y:.6,w:24},{x:-46,z:16,y:0,w:25}],Ce=[78,212,354,492,634,776],we=[{d:132,lateral:-4.5},{d:276,lateral:4.5},{d:418,lateral:0},{d:556,lateral:-4.6},{d:694,lateral:4.3},{d:820,lateral:0}],Te=[{x:0,z:0,y:0,w:26},{x:86,z:-6,y:.4,w:26},{x:176,z:-8,y:1.8,w:25},{x:264,z:12,y:4.2,w:25},{x:338,z:62,y:7.4,w:24},{x:376,z:138,y:10.2,w:24},{x:354,z:222,y:11.4,w:23},{x:288,z:284,y:9.6,w:23},{x:204,z:302,y:7.2,w:22},{x:126,z:254,y:4.8,w:22},{x:52,z:282,y:6.4,w:22},{x:-24,z:326,y:8.6,w:23},{x:-108,z:318,y:7.8,w:24},{x:-182,z:268,y:5.6,w:24},{x:-224,z:192,y:3.8,w:23},{x:-196,z:116,y:2.2,w:22},{x:-144,z:64,y:1.6,w:22},{x:-188,z:-4,y:2.8,w:23},{x:-164,z:-68,y:2,w:24},{x:-96,z:-56,y:.8,w:24},{x:-56,z:-12,y:.1,w:25}],Ee=[96,258,424,592,760,928,1096,1264,1432,1590],De=[{d:168,lateral:-4.6},{d:338,lateral:4.6},{d:508,lateral:0},{d:676,lateral:-4.6},{d:844,lateral:4.5},{d:1012,lateral:0},{d:1180,lateral:-4.5},{d:1348,lateral:4.5},{d:1512,lateral:0},{d:1648,lateral:-4.2}],Oe=[{x:0,z:0,y:0,w:26},{x:70,z:-6,y:.4,w:26},{x:140,z:-4,y:1.8,w:25},{x:200,z:22,y:4.2,w:24},{x:236,z:72,y:5.6,w:24},{x:232,z:130,y:5,w:24},{x:195,z:172,y:3.5,w:23},{x:145,z:174,y:2.2,w:23},{x:108,z:136,y:1.4,w:22},{x:75,z:164,y:1.6,w:22},{x:40,z:208,y:2.6,w:22},{x:-5,z:212,y:3.4,w:23},{x:-58,z:238,y:3.6,w:24},{x:-110,z:210,y:3,w:24},{x:-136,z:146,y:2,w:23},{x:-112,z:82,y:1.2,w:23},{x:-140,z:24,y:.5,w:24},{x:-105,z:-28,y:.2,w:25},{x:-52,z:-16,y:.1,w:25}],ke=[120,340,560,780,980],Ae=[{d:180,lateral:-4.5},{d:390,lateral:4.5},{d:620,lateral:0},{d:840,lateral:-4.5},{d:1040,lateral:4.2}],K=new W(le),je=new W(pe),Me=new W(ge),Ne=new W(ye),Pe=new W(Se),Fe=new W(Te),Ie=new W(Oe),Le={candy:{id:`candy`,nameKey:`map.candy`,taglineKey:`map.candy.desc`,track:K,boxDistances:fe,padPlacements:G},forest:{id:`forest`,nameKey:`map.forest`,taglineKey:`map.forest.desc`,track:je,boxDistances:me,padPlacements:he},beach:{id:`beach`,nameKey:`map.beach`,taglineKey:`map.beach.desc`,track:Me,boxDistances:_e,padPlacements:ve},frosthold:{id:`frosthold`,nameKey:`map.frosthold`,taglineKey:`map.frosthold.desc`,track:Ne,boxDistances:be,padPlacements:xe},ember:{id:`ember`,nameKey:`map.ember`,taglineKey:`map.ember.desc`,track:Pe,boxDistances:Ce,padPlacements:we},skyway:{id:`skyway`,nameKey:`map.skyway`,taglineKey:`map.skyway.desc`,track:Fe,boxDistances:Ee,padPlacements:De},noel:{id:`noel`,nameKey:`map.noel`,taglineKey:`map.noel.desc`,track:Ie,boxDistances:ke,padPlacements:Ae}},q=[{id:0,key:`racer.luna`,color:`#ff5ca8`,stats:[84,88,90,92],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><path d="M4 11 Q1 9 3 6 Q6 7 8 10" fill="#ff3d85"/><path d="M3 15 Q0 15 2 13 Q6 13 8 14" fill="#7ef9ff"/><path d="M4 19 Q1 22 4 23 Q6 21 8 18" fill="#ff3d85"/><path d="M28 11 Q31 9 29 6 Q26 7 24 10" fill="#ff3d85"/><path d="M29 15 Q32 15 30 13 Q26 13 24 14" fill="#7ef9ff"/><path d="M28 19 Q31 22 28 23 Q26 21 24 18" fill="#ff3d85"/><circle cx="16" cy="17" r="9.5" fill="#ffd6eb"/><path d="M12 9.5 Q16 8 20 9.5" stroke="#ffe066" stroke-width="1.6" fill="none"/><polygon points="16,6.5 17.5,9 20,9.2 18,11 18.5,13.5 16,12 13.5,13.5 14,11 12,9.2 14.5,9" fill="#7ef9ff"/><ellipse cx="12" cy="16.5" rx="2" ry="2.6" fill="#2e1534"/><ellipse cx="20" cy="16.5" rx="2" ry="2.6" fill="#2e1534"/><circle cx="11.4" cy="15.5" r="0.9" fill="#fff"/><circle cx="19.4" cy="15.5" r="0.9" fill="#fff"/><circle cx="12.7" cy="17.6" r="0.45" fill="#fff"/><circle cx="20.7" cy="17.6" r="0.45" fill="#fff"/><ellipse cx="9.5" cy="19" rx="2" ry="1.2" fill="#ff6fae" opacity=".8"/><ellipse cx="22.5" cy="19" rx="2" ry="1.2" fill="#ff6fae" opacity=".8"/><path d="M14 19.5 Q16 21 18 19.5" stroke="#2e1534" stroke-width="1" fill="none" stroke-linecap="round"/><circle cx="16" cy="20.4" r="0.8" fill="#ff4d79"/></svg>`},{id:1,key:`racer.pip`,color:`#2e86de`,stats:[90,82,85,88],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><circle cx="16" cy="17" r="10" fill="#223659"/><ellipse cx="16" cy="18" rx="7.5" ry="7" fill="#fff9f2"/><rect x="7" y="7" width="18" height="5" rx="2.5" fill="#ff4d79"/><circle cx="16" cy="6" r="2.2" fill="#fff9f2"/><circle cx="11.5" cy="10" r="3.2" fill="#ffe066" stroke="#b8860b" stroke-width="0.9"/><circle cx="20.5" cy="10" r="3.2" fill="#ffe066" stroke="#b8860b" stroke-width="0.9"/><circle cx="11.5" cy="10" r="2.2" fill="#7ef9ff"/><circle cx="20.5" cy="10" r="2.2" fill="#7ef9ff"/><ellipse cx="12.5" cy="16.5" rx="1.8" ry="2.2" fill="#223659"/><ellipse cx="19.5" cy="16.5" rx="1.8" ry="2.2" fill="#223659"/><circle cx="12" cy="15.8" r="0.8" fill="#fff"/><circle cx="19" cy="15.8" r="0.8" fill="#fff"/><polygon points="16,17.5 13.5,20.2 18.5,20.2" fill="#ffa801"/><ellipse cx="9.5" cy="18.8" rx="1.6" ry="1" fill="#ff7675" opacity=".7"/><ellipse cx="22.5" cy="18.8" rx="1.6" ry="1" fill="#ff7675" opacity=".7"/></svg>`},{id:2,key:`racer.boba`,color:`#ff9f43`,stats:[88,92,84,86],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><polygon points="6,13 9,4 15,10" fill="#f39c12"/><polygon points="8.5,11 10,6 14,10" fill="#ffccd5"/><polygon points="26,13 23,4 17,10" fill="#f39c12"/><polygon points="23.5,11 22,6 18,10" fill="#ffccd5"/><circle cx="16" cy="17" r="9.5" fill="#f39c12"/><ellipse cx="16" cy="19" rx="6" ry="5" fill="#fff5e4"/><ellipse cx="11.5" cy="13" rx="1.4" ry="1.1" fill="#fff5e4"/><ellipse cx="20.5" cy="13" rx="1.4" ry="1.1" fill="#fff5e4"/><ellipse cx="12" cy="16.5" rx="1.8" ry="2.2" fill="#2e1534"/><ellipse cx="20" cy="16.5" rx="1.8" ry="2.2" fill="#2e1534"/><circle cx="11.4" cy="15.8" r="0.8" fill="#fff"/><circle cx="19.4" cy="15.8" r="0.8" fill="#fff"/><ellipse cx="16" cy="18" rx="1.4" ry="1" fill="#2e1534"/><path d="M14.5 19.5 Q16 20.8 17.5 19.5" stroke="#2e1534" stroke-width="0.9" fill="none"/><path d="M10 24 L16 28 L22 24 Z" fill="#52ebbf"/><circle cx="16" cy="25.5" r="1.5" fill="#ffd447"/></svg>`},{id:3,key:`racer.sora`,color:`#9b59b6`,stats:[95,78,82,94],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><path d="M10,12 Q7,4 3,7 Q8,9 11,13" fill="#ffdf6b"/><path d="M22,12 Q25,4 29,7 Q24,9 21,13" fill="#ffdf6b"/><path d="M6 17 Q2 15 3 20 Q7 19 8 18" fill="#6ce8ff"/><path d="M26 17 Q30 15 29 20 Q25 19 24 18" fill="#6ce8ff"/><circle cx="16" cy="17" r="9.5" fill="#c896ff"/><polygon points="16,8.5 17.8,12 14.2,12" fill="#ffdf6b"/><ellipse cx="16" cy="19.5" rx="5.5" ry="4" fill="#e0b8ff"/><ellipse cx="12" cy="16" rx="2" ry="2.5" fill="#2e1534"/><ellipse cx="20" cy="16" rx="2" ry="2.5" fill="#2e1534"/><circle cx="11.3" cy="15.2" r="0.8" fill="#ffdf6b"/><circle cx="19.3" cy="15.2" r="0.8" fill="#ffdf6b"/><circle cx="12.5" cy="17" r="0.4" fill="#fff"/><circle cx="20.5" cy="17" r="0.4" fill="#fff"/><path d="M14.5 19.8 Q16 21.2 17.5 19.8" stroke="#2e1534" stroke-width="0.9" fill="none"/><ellipse cx="9" cy="18.5" rx="1.6" ry="1" fill="#ff9ff3" opacity=".7"/><ellipse cx="23" cy="18.5" rx="1.6" ry="1" fill="#ff9ff3" opacity=".7"/></svg>`},{id:4,key:`racer.yuzu`,color:`#2ecc71`,stats:[82,86,94,88],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><circle cx="9" cy="11" r="3" fill="#8a532a"/><circle cx="23" cy="11" r="3" fill="#8a532a"/><rect x="8" y="10" width="16" height="15" rx="6.5" fill="#ba7a48"/><rect x="9.5" y="15" width="13" height="9" rx="4.5" fill="#9e6235"/><circle cx="16" cy="7.2" r="3.4" fill="#ffe066"/><ellipse cx="17" cy="4.2" rx="1.8" ry="0.9" transform="rotate(25 17 4.2)" fill="#2ecc71"/><path d="M10.5 15.5 Q12.5 13.5 14.5 15.5" stroke="#2e1534" stroke-width="1.5" fill="none" stroke-linecap="round"/><path d="M17.5 15.5 Q19.5 13.5 21.5 15.5" stroke="#2e1534" stroke-width="1.5" fill="none" stroke-linecap="round"/><ellipse cx="14.5" cy="19" rx="0.9" ry="0.7" fill="#2e1534"/><ellipse cx="17.5" cy="19" rx="0.9" ry="0.7" fill="#2e1534"/><path d="M14.8 21 Q16 22 17.2 21" stroke="#2e1534" stroke-width="0.9" fill="none"/><ellipse cx="9" cy="18" rx="1.6" ry="1" fill="#ff7675" opacity=".6"/><ellipse cx="23" cy="18" rx="1.6" ry="1" fill="#ff7675" opacity=".6"/></svg>`},{id:5,key:`racer.pico`,color:`#ffbe3b`,stats:[80,94,92,85],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><circle cx="6.5" cy="11.5" r="5" fill="#a4b0be"/><circle cx="6.5" cy="11.5" r="3.2" fill="#ffc2d8"/><circle cx="25.5" cy="11.5" r="5" fill="#a4b0be"/><circle cx="25.5" cy="11.5" r="3.2" fill="#ffc2d8"/><circle cx="16" cy="17" r="9.5" fill="#a4b0be"/><path d="M10 11 Q16 8.5 22 11 Z" fill="#ff5c8a"/><rect x="15.2" y="6.8" width="1.6" height="3" fill="#333"/><ellipse cx="16" cy="6.2" rx="5.5" ry="1.3" fill="#ffd447"/><ellipse cx="11.5" cy="16" rx="1.8" ry="2.2" fill="#2d3436"/><ellipse cx="20.5" cy="16" rx="1.8" ry="2.2" fill="#2d3436"/><circle cx="11" cy="15.2" r="0.8" fill="#fff"/><circle cx="20" cy="15.2" r="0.8" fill="#fff"/><ellipse cx="16" cy="18.5" rx="2.8" ry="3.6" fill="#2d3436"/><ellipse cx="9" cy="18.5" rx="1.6" ry="1" fill="#ff5c8a" opacity=".65"/><ellipse cx="23" cy="18.5" rx="1.6" ry="1" fill="#ff5c8a" opacity=".65"/></svg>`},{id:6,key:`racer.coral`,color:`#ff6f91`,stats:[89,90,91,90],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><ellipse cx="11" cy="6.5" rx="2.8" ry="6" fill="#ffc7d7"/><ellipse cx="11" cy="6.8" rx="1.5" ry="4.2" fill="#ff6f91"/><ellipse cx="21" cy="6.5" rx="2.8" ry="6" fill="#ffc7d7"/><ellipse cx="21" cy="6.8" rx="1.5" ry="4.2" fill="#ff6f91"/><circle cx="16" cy="18" r="9" fill="#ffc7d7"/><ellipse cx="12.2" cy="17" rx="1.8" ry="2.3" fill="#2e1534"/><ellipse cx="19.8" cy="17" rx="1.8" ry="2.3" fill="#2e1534"/><circle cx="11.7" cy="16.2" r="0.8" fill="#fff"/><circle cx="19.3" cy="16.2" r="0.8" fill="#fff"/><polygon points="16,18.2 14.6,20 17.4,20" fill="#ff6f91"/><ellipse cx="9.2" cy="19.2" rx="1.7" ry="1" fill="#ff6f91" opacity=".65"/><ellipse cx="22.8" cy="19.2" rx="1.7" ry="1" fill="#ff6f91" opacity=".65"/></svg>`},{id:7,key:`racer.mochi`,color:`#8c7bff`,stats:[92,87,88,95],svg:`<svg viewBox="0 0 32 32" aria-hidden="true"><polygon points="6,13 8,4 15,10" fill="#f6efff"/><polygon points="8,11 9.5,6 14,10" fill="#8c7bff"/><polygon points="26,13 24,4 17,10" fill="#f6efff"/><polygon points="24,11 22.5,6 18,10" fill="#8c7bff"/><circle cx="16" cy="17.5" r="9.2" fill="#f6efff"/><circle cx="16" cy="11.2" r="2" fill="#ffd166"/><ellipse cx="12" cy="17" rx="1.9" ry="2.3" fill="#2e1534"/><ellipse cx="20" cy="17" rx="1.9" ry="2.3" fill="#2e1534"/><circle cx="11.4" cy="16.2" r="0.8" fill="#fff"/><circle cx="19.4" cy="16.2" r="0.8" fill="#fff"/><path d="M14 20 Q16 21.4 18 20" stroke="#2e1534" stroke-width="1" fill="none" stroke-linecap="round"/><ellipse cx="9" cy="19" rx="1.6" ry="1" fill="#ff8fab" opacity=".7"/><ellipse cx="23" cy="19" rx="1.6" ry="1" fill="#ff8fab" opacity=".7"/></svg>`}],J={balanced:{maxSpeed:w.kart.maxSpeed,acceleration:w.kart.acceleration,turnRate:w.kart.turnRate,boost1:w.drift.boost1},speed:{maxSpeed:44,acceleration:21,turnRate:1.7,boost1:1},drift:{maxSpeed:39,acceleration:28,turnRate:2.3,boost1:1.4},grip:{maxSpeed:35,acceleration:31,turnRate:2.7,boost1:1.1}},Y={critter:`<svg viewBox="0 0 28 28" aria-hidden="true"><ellipse cx="9" cy="7" rx="3" ry="5" fill="#fff"/><ellipse cx="19" cy="7" rx="3" ry="5" fill="#fff"/><circle cx="14" cy="16" r="8.5" fill="#fff"/><circle cx="11" cy="15.5" r="1.6" fill="#38183b"/><circle cx="17" cy="15.5" r="1.6" fill="#38183b"/><ellipse cx="8.5" cy="17.5" rx="1.6" ry="1" fill="#ff6fae"/><ellipse cx="19.5" cy="17.5" rx="1.6" ry="1" fill="#ff6fae"/></svg>`,candy:`<svg viewBox="0 0 28 28" aria-hidden="true"><circle cx="14" cy="14" r="10" fill="currentColor"/><path d="M14 4a10 10 0 0 1 8.6 5H14V4Zm0 20a10 10 0 0 1-8.6-5H14v5ZM6 9.5A10 10 0 0 1 11 4.5L14 14 6 9.5Zm16 9A10 10 0 0 1 17 23.5L14 14l8 4.5Z" fill="#fff" opacity=".42"/><circle cx="14" cy="14" r="3.6" fill="#fff"/></svg>`,star:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2 3 6.6 7.2.8-5.4 4.9 1.5 7.1L12 17.8 5.7 21.4l1.5-7.1L1.8 9.4 9 8.6Z" fill="currentColor"/></svg>`,pause:`<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="4" width="5" height="16" rx="1.5" fill="currentColor"/><rect x="14" y="4" width="5" height="16" rx="1.5" fill="currentColor"/></svg>`,boost:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M13 2 4 14h7l-1 8 10-12h-7l0-8Z" fill="currentColor"/></svg>`,gumball:`<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="currentColor"/><circle cx="9" cy="9" r="3" fill="#fff" opacity=".6"/></svg>`,puddle:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3c3.5 4.5 7 8 7 12a7 7 0 1 1-14 0c0-4 3.5-7.5 7-12Z" fill="currentColor"/></svg>`,shield:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2 4 5.5v6c0 5.2 3.4 9.8 8 11 4.6-1.2 8-5.8 8-11v-6L12 2Z" fill="currentColor"/></svg>`,pulse:`<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4" fill="currentColor"/><circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" stroke-width="2.4"/><circle cx="12" cy="12" r="11" fill="none" stroke="currentColor" stroke-width="1.4" opacity=".6"/></svg>`,tree:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2 4 13h4.5L5 18h14l-3.5-5H20L12 2Z" fill="currentColor"/><rect x="10.5" y="18" width="3" height="4" rx="0.8" fill="currentColor"/></svg>`,beach:`<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="17.5" cy="6.5" r="3.5" fill="currentColor"/><path d="M3 16c2.2 0 3.2-2 5.4-2s3.2 2 5.4 2 3.2-2 5.4-2 2.8 1.5 2.8 1.5v2.5s-.8-1.5-2.8-1.5-3.2 2-5.4 2-3.2-2-5.4-2-3.2 2-5.4 2V16Zm0 4.5c2.2 0 3.2-1.5 5.4-1.5s3.2 1.5 5.4 1.5 3.2-1.5 5.4-1.5 2.8 1.2 2.8 1.2V22H3v-1.5Z" fill="currentColor"/></svg>`,frosthold:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2v20M2 12h20m-15-7 14 14m0-14L7 19" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/><circle cx="12" cy="12" r="2.8" fill="currentColor"/></svg>`,ember:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2c2 4 6 7 6 12a6 6 0 1 1-12 0c0-3 2-6 3-8 1 2 2 3 3 3s1-2 0-7Z" fill="currentColor"/></svg>`,skyway:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2 14.5 9 22 9.5 16.5 14 18.5 21 12 17 5.5 21 7.5 14 2 9.5 9.5 9Z" fill="currentColor"/></svg>`,noel:`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2 8 8h3l-4 6h3.5L6 20h12l-4.5-6H17l-4-6h3L12 2Z" fill="currentColor"/><circle cx="12" cy="2" r="1.5" fill="#ffd700"/><circle cx="10" cy="9.5" r="1" fill="#ff4d4d"/><circle cx="14" cy="13.5" r="1" fill="#4dd2ff"/><circle cx="11" cy="17" r="1" fill="#ffd700"/></svg>`};function X(e,t){let n=e.samples,r=1/0,i=-1/0,a=1/0,o=-1/0;for(let e of n)e.x<r&&(r=e.x),e.x>i&&(i=e.x),e.z<a&&(a=e.z),e.z>o&&(o=e.z);r-=22,i+=22,a-=22,o+=22;let s=Math.max(i-r,o-a),c=(s-(i-r))*.5,l=(s-(o-a))*.5,u=(e,t)=>({u:(e-r+c)/s*100,v:(t-a+l)/s*100}),d=[];for(let e=0;e<n.length;e+=4){let{u:t,v:r}=u(n[e].x,n[e].z);d.push(`${e===0?`M`:`L`}${t.toFixed(1)},${r.toFixed(1)}`)}d.push(`Z`);let f=u(n[0].x,n[0].z),p=t.map(t=>{let n=e.at(t.d,t.lateral);return u(n.x,n.z)});return{path:d.join(` `),start:f,pads:p,project:u}}var Z={candy:X(K,G),forest:X(je,he),beach:X(Me,ve),frosthold:X(Ne,xe),ember:X(Pe,we),skyway:X(Fe,De),noel:X(Ie,Ae)},Q={keyboard:{keys:`<kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd>`,jump:`<kbd class="wide">Space</kbd>`,dash:`<kbd>E</kbd>`,select:`<kbd>Enter</kbd>`,back:`<kbd>Esc</kbd>`},gamepad:{keys:`<kbd class="round">L</kbd>`,stickR:`<kbd class="round">R</kbd>`,jump:`<kbd class="round a">A</kbd>`,dash:`<kbd class="round x">X</kbd>`,select:`<kbd class="round a">A</kbd>`,back:`<kbd class="round b">B</kbd>`}},Re=class{i18n;save;audio;input;actions;screen=`boot`;root;stack=[];hudCache=new Map;hintKey=null;navRepeat=0;lastRace;lastHud;savedRank=-1;lastMethod=``;lastLap=0;constructor(e,t,n,r,i){this.i18n=e,this.save=t,this.audio=n,this.input=r,this.actions=i,this.root=document.getElementById(`ui`),this.root.innerHTML=this.template(),this.root.addEventListener(`click`,e=>this.onClick(e)),this.root.addEventListener(`input`,e=>this.onInput(e)),this.root.addEventListener(`focusin`,e=>{e.target.matches(`.btn, .seg button, .toggle`)&&this.audio.play(`ui`)}),window.addEventListener(`keydown`,e=>this.onKey(e)),e.onChange(()=>this.translate()),this.translate(),this.refreshSettings()}show(e){this.stack.length=0,this.setScreen(e)}push(e){this.stack.push(this.screen),this.setScreen(e)}back(){let e=this.stack.pop();e?this.setScreen(e):this.screen===`pause`&&this.actions.resume()}setScreen(e){this.screen=e;for(let t of this.root.querySelectorAll(`[data-screen]`)){let n=t.dataset.screen===e||t.dataset.screen===`hud`&&(e===`pause`||e===`results`||e===`settings`&&this.stack.includes(`pause`));t.classList.toggle(`is-active`,n),t.setAttribute(`aria-hidden`,String(!n))}this.root.dataset.activeScreen=e,e===`title`&&(this.renderBest(),this.refreshCircuitPills()),e!==`hud`&&(this.lastLap=0,this.q(`.final-lap-vignette`)?.classList.remove(`is-active`),this.q(`.hud-lap`)?.classList.remove(`is-final-lap`,`lap-advance`)),e===`leaderboard`&&this.renderLeaderboard(),requestAnimationFrame(()=>{let e=this.navItems()[0];e&&this.input.method!==`touch`?e.focus({preventScroll:!0}):document.activeElement?.blur?.()})}setBootProgress(e){let t=this.q(`.boot-bar i`);t.style.transform=`scaleX(${Math.max(.04,Math.min(1,e))})`}updateHud(e){this.lastHud=e;let{race:t}=e,n=`place.${Math.min(8,Math.max(1,t.place))}`;this.set(`place`,this.i18n.t(n));let r=this.q(`.hud-place`);r.dataset.place=String(t.place),this.set(`lap`,`${t.lap}<small>/${t.laps}</small>`);let i=this.q(`.hud-lap`);this.lastLap!==t.lap&&(this.lastLap>0&&t.phase===`racing`&&(i.classList.remove(`lap-advance`),i.offsetWidth,i.classList.add(`lap-advance`)),this.lastLap=t.lap);let a=t.lap===t.laps&&t.phase===`racing`;i.classList.toggle(`is-final-lap`,a),this.q(`.final-lap-vignette`)?.classList.toggle(`is-active`,a),this.set(`score`,t.score.toLocaleString(this.i18n.locale)),this.set(`clock`,F(t.clock));let o=this.q(`.hud-countdown`),s=t.phase===`countdown`&&t.countdown>0;o.classList.toggle(`is-active`,s),s&&this.set(`countdown`,String(Math.ceil(t.countdown)));let c=this.q(`.hud-item`),l=e.heldItem??e.rollingItem;c.dataset.state=e.heldItem?`ready`:e.rollingItem?`rolling`:`empty`,c.dataset.item=l??`none`,l?(this.set(`item-icon`,Y[l]??Y.candy),this.set(`item-label`,e.heldItem?this.i18n.t(`item.${l}`):this.i18n.t(`hud.rolling`))):(this.set(`item-icon`,Y.candy),this.set(`item-label`,this.i18n.t(`hud.itemEmpty`))),this.set(`speed`,String(e.speedKmh));let u=Math.min(1,e.speedKmh/150);this.q(`.hud-speed-bar i`).style.transform=`scaleX(${u.toFixed(3)})`,this.q(`.hud-drift-meter`).classList.toggle(`is-active`,e.driftCharge>.02||e.boosting),this.q(`.hud-drift-meter i`).style.transform=`scaleX(${(e.boosting?1:e.driftCharge).toFixed(3)})`;let d=this.q(`.hud-drift-badge`);e.boosting?(d.dataset.tier=`boost`,this.set(`drift-badge`,this.i18n.t(`hud.boost`))):e.driftTier>0?(d.dataset.tier=String(e.driftTier),this.set(`drift-badge`,`${this.i18n.t(`hud.drift`)} ×${e.driftTier}`)):(d.dataset.tier=`0`,this.set(`drift-badge`,``)),this.q(`.hud-wrongway`).classList.toggle(`is-active`,e.wrongWay),this.q(`.boost-vignette`).classList.toggle(`is-active`,e.boosting&&!this.save.data.reducedMotion);let f=e.standings.map(e=>{let t=`#${e.color.toString(16).padStart(6,`0`)}`,n=e.key.startsWith(`racer.`)?e.key:`racer.${e.key}`,r=q.find(e=>e.key===n)?.svg??``,i=this.i18n.t(n);return`<li class="${e.isPlayer?`is-me`:``}"><b>${e.place}</b><i style="background:${t}">${r}</i><span>${i}</span></li>`}).join(``);this.set(`standings`,f);let p=this.save.data.map||`candy`;this.syncMinimapTrack(p);let m=Z[p]??Z.candy,h=[...e.standings].sort((e,t)=>Number(e.isPlayer)-Number(t.isPlayer)).map(e=>{let{u:t,v:n}=m.project(e.x,e.z),r=`#${e.color.toString(16).padStart(6,`0`)}`;if(!e.isPlayer)return`<circle cx="${t.toFixed(1)}" cy="${n.toFixed(1)}" r="3.4" fill="${r}" stroke="#221638" stroke-width="1.1"/>`;let i=(-e.heading*180/Math.PI+180).toFixed(1);return`<g transform="translate(${t.toFixed(1)},${n.toFixed(1)}) rotate(${i})"><polygon points="0,-6.4 4.6,4.6 0,2.4 -4.6,4.6" fill="${r}" stroke="#fff8ee" stroke-width="1.5" stroke-linejoin="round"/></g>`}).join(``);this.set(`minimap-dots`,h)}currentMinimapMap=null;syncMinimapTrack(e){if(this.currentMinimapMap===e)return;this.currentMinimapMap=e;let t=Z[e]??Z.candy;this.root.querySelector(`.minimap-border`)?.setAttribute(`d`,t.path),this.root.querySelector(`.minimap-road`)?.setAttribute(`d`,t.path);let n=t.pads.map(e=>`<circle class="minimap-pad" cx="${e.u.toFixed(1)}" cy="${e.v.toFixed(1)}" r="1.9" />`).join(``),r=this.root.querySelector(`.minimap-start`);r&&(r.setAttribute(`cx`,t.start.u.toFixed(1)),r.setAttribute(`cy`,t.start.v.toFixed(1)));let i=this.root.querySelector(`.minimap-pads`);i&&(i.innerHTML=n)}popup(e,t,n){let r=document.createElement(`div`);r.className=`popup popup-${n}`,r.textContent=e,r.style.left=`${t.x}px`,r.style.top=`${t.y}px`,this.q(`.popups`).append(r),r.addEventListener(`animationend`,()=>r.remove())}hurt(){let e=this.q(`.hurt-vignette`);e.classList.remove(`flash`),e.offsetWidth,e.classList.add(`flash`)}hint(e){this.hintKey=e,this.renderHint()}renderHint(){let e=this.q(`.hint`),t=this.hintKey;if(!t){e.classList.remove(`is-active`);return}let n=this.input.method,r=n===`gamepad`?Q.gamepad:Q.keyboard,i=`hint.${t}.${n}`,a={keys:r.keys,stick:Q.gamepad.keys,key:t===`item`?r.dash:r.jump};e.querySelector(`span`).innerHTML=this.i18n.t(i,a),e.classList.add(`is-active`)}banner(e){let t=this.q(`.banner`),n=e.match(/^LAP\s+(\d+)\/(\d+)$/);t.textContent=e===`GO!`?this.i18n.t(`hud.go`):e===`FINAL LAP!`?this.i18n.t(`hud.finalLap`):e===`FREE CAM 360°`?this.i18n.t(`hud.freeCam`):e===`CHASE CAM`?this.i18n.t(`hud.chaseCam`):n?this.i18n.t(`hud.lapBanner`,{lap:n[1],total:n[2]}):e,t.classList.toggle(`is-final-lap`,e===`FINAL LAP!`),t.classList.remove(`show`),t.offsetWidth,t.classList.add(`show`)}showResults(e){let{race:t}=e;this.lastHud=e,this.lastRace=t,this.savedRank=-1;let n=t.place<=3;this.q(`[data-screen="results"]`).classList.toggle(`is-won`,n);let r=t.place===1?`results.won`:t.place<=3?`results.podium`:`results.finished`;this.q(`.results-title`).setAttribute(`data-i18n`,r);let i=ae(t.place);for(let[e,t]of this.qa(`.results-stars .star`).entries())t.classList.toggle(`is-on`,e<i),t.style.animationDelay=`${.35+e*.22}s`;let a=e=>e.toLocaleString(this.i18n.locale),o=D[t.place-1]??0,s=t.driftBoosts*T.score.driftBoost,c=t.hits*T.score.hit;this.q(`.r-place`).textContent=this.i18n.t(`place.${Math.min(8,Math.max(1,t.place))}`),this.q(`.r-place-score`).textContent=`+${a(o)}`,this.q(`.r-time`).textContent=F(t.clock),this.q(`.r-best-lap`).textContent=t.bestLap>0?F(t.bestLap):`—`,this.q(`.r-drift-count`).textContent=`×${t.driftBoosts}`,this.q(`.r-drift-bonus`).textContent=`+${a(s)}`,this.q(`.r-hit-count`).textContent=`×${t.hits}`,this.q(`.r-hit-bonus`).textContent=`+${a(c)}`,this.q(`.r-total`).textContent=a(t.score),this.renderResultsStandings(e);let l=this.save.data.leaderboard[0]?.score??0;this.q(`.results-best`).classList.toggle(`is-active`,!t.unranked&&t.score>l&&t.score>0);let u=this.q(`.results-save`);u.classList.toggle(`is-hidden`,t.unranked||t.score<=0||v(this.save.data.leaderboard,this.entry(t)).rank<0),u.classList.remove(`is-saved`),this.q(`.results-name`).value=this.save.data.playerName,this.q(`.results-rank`).textContent=``,this.translate(),this.show(`results`)}renderResultsStandings(e){let t=this.q(`.results-standings`);t.innerHTML=e.standings.map(e=>{let t=`#${e.color.toString(16).padStart(6,`0`)}`,n=e.key.startsWith(`racer.`)?e.key:`racer.${e.key}`,r=q.find(e=>e.key===n)?.svg??``,i=this.i18n.t(n),a=e.finishTime===null?`—`:F(e.finishTime);return`<li class="${e.isPlayer?`is-me`:``}"><b>${e.place}</b><i style="background:${t}">${r}</i><span>${i}</span><em>${a}</em></li>`}).join(``)}entry(e){return{name:this.q(`.results-name`)?.value.trim().slice(0,16)||this.save.data.playerName,score:e.score,seconds:Math.round(e.clock),at:Date.now()}}saveScore(){if(!this.lastRace||this.lastRace.unranked||this.savedRank>=0)return;let e=this.entry(this.lastRace),{board:t,rank:n}=v(this.save.data.leaderboard,e);this.save.update({leaderboard:t,playerName:e.name}),this.savedRank=n,this.q(`.results-save`).classList.add(`is-saved`),this.q(`.results-rank`).textContent=n>=0?this.i18n.t(`results.rank`,{rank:n+1}):``,this.audio.play(`ui`)}renderLeaderboard(){let e=this.q(`.board`),t=this.save.data.leaderboard;if(t.length===0){e.innerHTML=`<li class="board-empty">${this.i18n.t(`leaderboard.empty`)}</li>`;return}e.innerHTML=t.map((e,t)=>`<li class="${t===this.savedRank?`is-me`:``}"><b>${t+1}</b><span class="board-name"></span><span>${F(e.seconds)}</span><em>${e.score.toLocaleString(this.i18n.locale)}</em></li>`).join(``),e.querySelectorAll(`.board-name`).forEach((e,n)=>e.textContent=t[n].name)}renderBest(){let e=this.save.data.leaderboard[0]?.score??0,t=this.root.querySelector(`.title-best`);t&&(t.classList.toggle(`is-hidden`,e<=0),t.textContent=this.i18n.t(`menu.best`,{score:e.toLocaleString(this.i18n.locale)}))}refreshSettings(){let e=this.save.data;this.q(`[name="musicVolume"]`).value=String(e.musicVolume),this.q(`[name="sfxVolume"]`).value=String(e.sfxVolume),this.q(`[name="sensitivity"]`).value=String(e.sensitivity);for(let t of this.qa(`.toggle`)){let n=e[t.dataset.setting]===!0;t.setAttribute(`aria-pressed`,String(n)),t.querySelector(`span`).setAttribute(`data-i18n`,n?`settings.on`:`settings.off`)}for(let t of this.qa(`.seg button`)){let n=t.parentElement.dataset.setting,r=e.quality;n===`locale`?r=this.i18n.locale:n===`map`?r=e.map:n===`laps`&&(r=e.laps),t.setAttribute(`aria-pressed`,String(t.dataset.value===String(r)))}for(let e of this.qa(`input[type="range"]`))e.style.setProperty(`--fill`,`${(Number(e.value)-Number(e.min))/(Number(e.max)-Number(e.min))*100}%`);this.refreshCircuitPills(),this.translate()}refreshCircuitPills(){let e=this.save.data;for(let t of this.qa(`.map-pill, .track-tile`))t.setAttribute(`aria-pressed`,String(t.dataset.map===e.map));for(let t of this.qa(`.lap-pill`))t.setAttribute(`aria-pressed`,String(Number(t.dataset.laps)===e.laps));for(let e of this.qa(`.lang-pill`))e.setAttribute(`aria-pressed`,String(e.dataset.locale===this.i18n.locale));let t=this.root.querySelector(`.top-sound-icon`);t&&(t.textContent=e.muted?`🔇`:`🔊`);let n=this.root.querySelector(`.top-lang-label`);n&&(n.textContent=this.i18n.locale===`zh-CN`?`ZH`:this.i18n.locale.toUpperCase())}onClick(e){let t=e.target.closest(`[data-action], .toggle, .seg button`);if(t){if(this.audio.unlock(),this.audio.startMusic(),t.matches(`.toggle`)){let e=t.dataset.setting;this.actions.settings({[e]:!this.save.data[e]}),this.refreshSettings(),this.audio.play(`ui`);return}if(t.matches(`.seg button`)){let e=t.parentElement.dataset.setting;if(e===`quality`&&this.actions.settings({quality:t.dataset.value}),e===`locale`&&this.actions.settings({locale:t.dataset.value}),e===`map`){let e=t.dataset.value;this.actions.settings({map:e}),this.actions.selectMap?.(e),this.refreshCircuitPills()}if(e===`laps`){let e=Number(t.dataset.value);this.actions.settings({laps:e}),this.actions.selectLaps?.(e),this.refreshCircuitPills()}this.refreshSettings(),this.audio.play(`ui`);return}switch(t.dataset.action){case`toggle-mute`:{let e=!this.save.data.muted;this.actions.settings({muted:e}),this.refreshSettings(),this.audio.play(`ui`);break}case`cycle-lang`:{let e=[`en`,`tr`,`zh-CN`],t=e[(e.indexOf(this.i18n.locale)+1)%e.length];this.actions.settings({locale:t}),this.refreshCircuitPills(),this.refreshSettings(),this.audio.play(`ui`);break}case`shelf-left`:this.q(`.track-cards-shelf`)?.scrollBy({left:-240,behavior:`smooth`}),this.audio.play(`ui`);break;case`shelf-right`:this.q(`.track-cards-shelf`)?.scrollBy({left:240,behavior:`smooth`}),this.audio.play(`ui`);break;case`play`:this.actions.play();break;case`resume`:this.actions.resume();break;case`restart`:this.actions.restart();break;case`quit`:this.actions.quit();break;case`settings`:this.push(`settings`);break;case`garage`:this.syncGarageControls(),this.push(`garage`);break;case`select-preset`:{let e=t.dataset.preset??`balanced`,n=J[e]??J.balanced;H.apply({"kart.maxSpeed":n.maxSpeed,"kart.acceleration":n.acceleration,"kart.turnRate":n.turnRate,"drift.boost1":n.boost1}),H.activate(`drift`);for(let t of this.qa(`.garage-preset-btn`))t.setAttribute(`aria-pressed`,String(t.dataset.preset===e));let r=this.root.querySelector(`.dyno-active-preset`);r&&(r.setAttribute(`data-i18n`,`garage.preset.${e}`),r.textContent=this.i18n.t(`garage.preset.${e}`)),this.syncGarageControls(),this.audio.play(`ui`);break}case`garage-reset`:{let e=J.balanced;H.apply({"kart.maxSpeed":e.maxSpeed,"kart.acceleration":e.acceleration,"kart.turnRate":e.turnRate,"drift.boost1":e.boost1}),H.activate(`drift`);for(let e of this.qa(`.garage-preset-btn`))e.setAttribute(`aria-pressed`,String(e.dataset.preset===`balanced`));let t=this.root.querySelector(`.dyno-active-preset`);t&&(t.setAttribute(`data-i18n`,`garage.preset.balanced`),t.textContent=this.i18n.t(`garage.preset.balanced`)),this.syncGarageControls(),this.audio.play(`ui`);break}case`leaderboard`:this.push(`leaderboard`);break;case`vip`:this.push(`vip`);try{window.webkit?.messageHandlers?.lollyBridge?.postMessage({type:`openVipModal`})}catch{}break;case`restore-vip`:this.audio.play(`ui`);try{window.webkit?.messageHandlers?.lollyBridge?.postMessage({type:`restoreVipPurchases`})}catch{}break;case`select-vip-plan`:{let e=t.dataset.plan??`annual`;for(let t of this.qa(`.vip-plan-card`))t.setAttribute(`aria-pressed`,String(t.dataset.plan===e));this.audio.play(`ui`);try{window.webkit?.messageHandlers?.lollyBridge?.postMessage({type:`purchaseVipPlan`,plan:e})}catch{}break}case`back`:this.back();break;case`save-score`:this.saveScore();break;case`use-item`:this.input.trigger(`dash`);break;case`pause`:window.dispatchEvent(new CustomEvent(`game:pause`));break;case`select-map`:{let e=t.dataset.map??`candy`;if(this.isDemoMode()&&!y(e,!0)){this.audio.play(`ui`),this.push(`vip`);return}this.actions.settings({map:e}),this.actions.selectMap?.(e),this.refreshCircuitPills(),this.refreshSettings(),this.audio.play(`ui`),t.scrollIntoView?.({behavior:`smooth`,inline:`center`,block:`nearest`});break}case`select-laps`:{let e=Number(t.dataset.laps??3);if(this.isDemoMode()&&!x(e,!0)){this.audio.play(`ui`),this.push(`vip`);return}this.actions.settings({laps:e}),this.actions.selectLaps?.(e),this.refreshCircuitPills(),this.refreshSettings(),this.audio.play(`ui`);break}case`select-racer`:this.selectRacerById(Number(t.dataset.racer??0));break;case`set-locale`:{let e=t.dataset.locale;this.actions.settings({locale:e}),this.refreshCircuitPills(),this.refreshSettings(),this.audio.play(`ui`);break}}}}isDemoMode(){try{return new URLSearchParams(window.location.search).has(`demo`)}catch{return!1}}selectRacerById(e){if(this.isDemoMode()&&!b(e,!0)){this.audio.play(`ui`),this.push(`vip`);return}let t=q[e]??q[0];for(let e of this.qa(`.racer-pill`))e.setAttribute(`aria-pressed`,String(Number(e.dataset.racer)===t.id));let n=this.q(`.racer-active-name`);n.setAttribute(`data-i18n`,t.key),n.textContent=this.i18n.t(t.key),this.updateDriverDynoStrip(t.id),this.audio.play(`ui`),this.actions.selectRacer?.(t.id)}updateDriverDynoStrip(e){let[t,n,r,i]=(q[e]??q[0]).stats,a=(e,t)=>{let n=this.root.querySelector(`.${e} i`);n&&(n.style.width=`${t}%`)};a(`dyno-bar-speed`,t),a(`dyno-bar-accel`,n),a(`dyno-bar-handling`,r),a(`dyno-bar-drift`,i)}syncGarageControls(){let e=H.read().requested,t=(e,t)=>{let n=this.root.querySelector(`[name="${e}"]`);n&&(n.value=String(t),n.style.setProperty(`--fill`,`${(Number(n.value)-Number(n.min))/(Number(n.max)-Number(n.min))*100}%`))};t(`garage_maxSpeed`,e[`kart.maxSpeed`]??w.kart.maxSpeed),t(`garage_acceleration`,e[`kart.acceleration`]??w.kart.acceleration),t(`garage_turnRate`,e[`kart.turnRate`]??w.kart.turnRate),t(`garage_boost1`,e[`drift.boost1`]??w.drift.boost1)}onInput(e){let t=e.target;if(t.type===`range`){if(t.style.setProperty(`--fill`,`${(Number(t.value)-Number(t.min))/(Number(t.max)-Number(t.min))*100}%`),t.name.startsWith(`garage_`)){let e=Number(t.value);t.name===`garage_maxSpeed`?H.apply({"kart.maxSpeed":e}):t.name===`garage_acceleration`?H.apply({"kart.acceleration":e}):t.name===`garage_turnRate`?H.apply({"kart.turnRate":e}):t.name===`garage_boost1`&&(H.apply({"drift.boost1":e}),H.activate(`drift`));return}this.actions.settings({[t.name]:Number(t.value)})}}onKey(e){if(this.screen===`hud`||this.screen===`boot`)return;let t=e.target.matches?.(`input[type="text"]`);if((e.code===`Escape`||e.code===`Backspace`&&!t)&&this.screen!==`title`){this.screen!==`pause`&&this.screen!==`results`&&(e.preventDefault(),this.input.consume(`pause`),this.back());return}if(this.screen===`title`&&(e.code===`ArrowLeft`||e.code===`ArrowRight`)){e.preventDefault();let t=this.root.querySelector(`.racer-pill[aria-pressed="true"]`),n=Number(t?.dataset.racer??0),r=e.code===`ArrowRight`?1:-1;this.selectRacerById((n+r+q.length)%q.length);return}if(this.screen===`title`&&(e.code===`Enter`||e.code===`Space`)){let t=document.activeElement;if(!t||t===document.body||t.matches(`.screen`)||t.matches(`.title-card`)||t.matches(`[data-action="play"]`)){e.preventDefault(),this.actions.play();return}}(e.code===`ArrowDown`||e.code===`ArrowUp`)&&(e.preventDefault(),this.moveFocus(e.code===`ArrowDown`?1:-1))}frame(e){if(this.input.method!==this.lastMethod&&(this.lastMethod=this.input.method,this.renderPrompts(),this.renderHint()),this.screen===`hud`||this.screen===`boot`)return;if(this.input.method!==`gamepad`){this.input.consume(`confirm`),this.input.consume(`back`);return}let t=this.input.move.y,n=this.input.move.x;this.navRepeat=Math.max(0,this.navRepeat-e);let r=document.activeElement;if(Math.abs(t)>.6&&this.navRepeat<=0)this.moveFocus(t<0?1:-1),this.navRepeat=.22;else if(Math.abs(n)>.6&&this.navRepeat<=0&&r?.matches(`input[type="range"]`)){let e=r;e.value=String(Number(e.value)+Math.sign(n)*Number(e.step||.1)),e.dispatchEvent(new Event(`input`,{bubbles:!0})),this.navRepeat=.12}else Math.abs(n)>.6&&this.navRepeat<=0&&r?.parentElement?.matches(`.seg`)?((Math.sign(n)>0?r.nextElementSibling:r.previousElementSibling)?.focus(),this.navRepeat=.22):Math.abs(t)<.3&&Math.abs(n)<.3&&(this.navRepeat=0);this.input.consume(`confirm`)&&r?.click(),this.input.consume(`back`)&&this.screen!==`title`&&this.back()}navItems(){return[...this.q(`[data-screen="${this.screen}"]`).querySelectorAll(`[data-nav]`)].filter(e=>e.offsetParent!==null&&!e.closest(`.is-hidden`))}moveFocus(e){let t=this.navItems();if(t.length===0)return;let n=[];for(let e of t){let t=e.parentElement?.matches(`.seg`)?e.parentElement:null,r=n[n.length-1];t&&r&&r[0].parentElement===t?r.push(e):n.push([e])}let r=n[(n.findIndex(e=>e.includes(document.activeElement))+e+n.length)%n.length];(r.find(e=>e.getAttribute(`aria-pressed`)===`true`)??r[0]).focus()}translate(){for(let e of this.root.querySelectorAll(`[data-i18n]`))e.textContent=this.i18n.t(e.dataset.i18n);for(let e of this.root.querySelectorAll(`[data-i18n-label]`))e.setAttribute(`aria-label`,this.i18n.t(e.dataset.i18nLabel));for(let e of this.root.querySelectorAll(`[data-i18n-placeholder]`))e.placeholder=this.i18n.t(e.dataset.i18nPlaceholder);this.renderPrompts(),this.renderHint(),this.screen===`title`&&this.renderBest(),this.screen===`leaderboard`&&this.renderLeaderboard(),this.hudCache.clear(),this.lastHud&&(this.updateHud(this.lastHud),this.renderResultsStandings(this.lastHud),this.lastRace&&(this.q(`.r-place`).textContent=this.i18n.t(`place.${Math.min(6,Math.max(1,this.lastRace.place))}`))),document.title=this.i18n.t(`game.title`)}renderPrompts(){let e=this.input.method===`gamepad`?Q.gamepad:Q.keyboard,t=this.input.method===`gamepad`?`<kbd class="round">R</kbd>`:`<kbd>Scroll</kbd><kbd>1-2-3</kbd>`,n=this.input.method===`gamepad`?`<kbd class="round">R3</kbd>`:`<kbd>C</kbd>`,r=this.input.method===`touch`?``:`<span>${e.select} ${this.i18n.t(`prompt.select`)}</span><span>${e.back} ${this.i18n.t(`prompt.back`)}</span><span>${t} ${this.i18n.t(`prompt.camera`)}</span><span>${n} ${this.i18n.t(`prompt.freeCam`)}</span>`;for(let e of this.qa(`.prompts`))e.innerHTML=r}set(e,t){if(this.hudCache.get(e)===t)return!1;this.hudCache.set(e,t);let n=this.root.querySelector(`[data-slot="${e}"]`);return n&&(n.innerHTML=t),!0}q(e){return this.root.querySelector(e)}qa(e){return[...this.root.querySelectorAll(e)]}template(){let e=(e,t,n,r,i)=>`<label class="row"><span data-i18n="${t}"></span><input data-nav type="range" name="${e}" min="${n}" max="${r}" step="${i}"></label>`,t=(e,t)=>`<div class="row"><span data-i18n="${t}"></span><button data-nav class="toggle" data-setting="${e}" aria-pressed="false"><i></i><span></span></button></div>`,n=Z.candy.pads.map(e=>`<circle class="minimap-pad" cx="${e.u.toFixed(1)}" cy="${e.v.toFixed(1)}" r="1.9" />`).join(``),r=this.isDemoMode(),i=q.map((e,t)=>`<button data-nav type="button" class="racer-pill${r&&t>0?` is-demo-locked`:``}" data-action="select-racer" data-racer="${e.id}" data-i18n-label="${e.key}" aria-pressed="${t===0}" style="--racer-color:${e.color}">${e.svg}${r&&t>0?`<span class="racer-lock-badge" aria-hidden="true">🔒</span>`:``}</button>`).join(``);return`
<section class="screen screen-boot is-active" data-screen="boot">
  <div class="boot-logo" data-i18n="game.title"></div>
  <div class="boot-bar"><i></i></div>
  <div class="boot-label" data-i18n="boot.loading"></div>
</section>

<section class="screen screen-title" data-screen="title">
  <div class="title-vignette"></div>
  <div class="title-best is-hidden"></div>

  <!-- Top Bar: Brand left, Controls right -->
  <header class="title-top-bar">
    <div class="title-brand">
      <h1 class="title-brand-text" data-i18n="game.title">LOLLY LAP</h1>
      <span class="title-brand-flag">🏁</span>
    </div>
    <div class="title-top-actions">
      <button data-nav type="button" class="top-vip-pill" data-action="vip">
        <span>👑</span>
        <span data-i18n="vip.button">PRO PASS</span>
      </button>
      <button data-nav type="button" class="top-icon-btn top-mute-btn" data-action="toggle-mute" aria-label="Mute Audio">
        <span class="top-sound-icon">🔊</span>
      </button>
      <button data-nav type="button" class="top-icon-btn" data-action="settings" aria-label="Settings">
        <span class="top-gear-icon">⚙️</span>
      </button>
      <button data-nav type="button" class="top-lang-pill" data-action="cycle-lang" aria-label="Language">
        <span class="top-lang-label">EN</span>
        <span class="top-lang-caret">▾</span>
      </button>
    </div>
  </header>

  <!-- Left Main Column: Circuit Select Card + Bottom Action Bar -->
  <div class="title-main-col">
    <section class="track-select-card" aria-label="Circuit Selection">
      <div class="track-card-header">
        <h2 class="track-card-title-main" data-i18n="menu.chooseTrack">CHOOSE YOUR CIRCUIT</h2>
        <p class="track-card-subtitle" data-i18n="menu.chooseTrackSub">Select a world, tune your kart, and join the race.</p>
      </div>
      <div class="track-grid-8" role="region" aria-label="Circuits">
        ${[...[`candy`,`forest`,`beach`,`frosthold`,`ember`,`skyway`,`noel`].map(e=>{let t=S[e],n=C[e],i=r&&e!==`candy`;return`
        <button data-nav type="button" class="track-tile map-pill${i?` is-demo-locked`:``}" data-action="select-map" data-map="${e}" aria-pressed="${e===`candy`}" style="--track-accent:${t.accentColor}" data-i18n-label="${t.nameKey}">
          <div class="track-tile-thumb">
            ${n}
            <div class="track-tile-overlay"></div>
            <div class="track-tile-check">${i?`🔒`:`✓`}</div>
          </div>
          <span class="track-tile-name" data-i18n="${t.nameKey}"></span>
        </button>`}),`
      <button data-nav type="button" class="track-tile track-tile-garage" data-action="garage" style="--track-accent:#6ce8ff" data-i18n-label="menu.garage">
        <div class="track-tile-thumb">
          ${C.soon}
          <div class="track-tile-overlay"></div>
          <div class="track-tile-lock">🔧</div>
        </div>
        <span class="track-tile-name" data-i18n="menu.garage">GARAGE & DYNO</span>
      </button>`].join(``)}
      </div>
    </section>

    <div class="bottom-controls-bar">
      <div class="laps-control-group">
        <span class="laps-control-label" data-i18n="menu.lapCount">LAPS</span>
        <div class="laps-seg-pills">
          <button data-nav type="button" class="lap-pill" data-action="select-laps" data-laps="2" aria-pressed="false">2</button>
          <button data-nav type="button" class="lap-pill" data-action="select-laps" data-laps="3" aria-pressed="true">3</button>
          <button data-nav type="button" class="lap-pill" data-action="select-laps" data-laps="5" aria-pressed="false">5</button>
          <button data-nav type="button" class="lap-pill" data-action="select-laps" data-laps="7" aria-pressed="false">7</button>
        </div>
      </div>
      <button data-nav type="button" class="bar-btn bar-btn-board" data-action="leaderboard">
        <span class="btn-emoji">🏆</span>
        <span data-i18n="menu.leaderboard">LEADERBOARD</span>
        <span class="btn-arrow">›</span>
      </button>
      <button data-nav type="button" class="bar-btn bar-btn-play" data-action="play">
        <span class="btn-emoji">🏁</span>
        <span data-i18n="menu.play">RACE NOW</span>
        <span class="btn-arrow">›</span>
      </button>
    </div>

    
      <div class="dyno-strip-row" role="group" aria-label="Kart Dyno Telemetry">
        <div class="dyno-stat-pill">
          <span class="dyno-stat-label" data-i18n="garage.stat.speed">Top Speed</span>
          <div class="dyno-bar dyno-bar-speed"><i style="width:84%"></i></div>
        </div>
        <div class="dyno-stat-pill">
          <span class="dyno-stat-label" data-i18n="garage.stat.accel">Acceleration</span>
          <div class="dyno-bar dyno-bar-accel"><i style="width:88%"></i></div>
        </div>
        <div class="dyno-stat-pill">
          <span class="dyno-stat-label" data-i18n="garage.stat.handling">Corner Grip</span>
          <div class="dyno-bar dyno-bar-handling"><i style="width:90%"></i></div>
        </div>
        <div class="dyno-stat-pill">
          <span class="dyno-stat-label" data-i18n="garage.stat.drift">Mini-Turbo</span>
          <div class="dyno-bar dyno-bar-drift"><i style="width:92%"></i></div>
        </div>
        <button data-nav type="button" class="dyno-tune-btn" data-action="garage">
          <span class="btn-emoji">🔧</span>
          <span class="dyno-active-preset" data-i18n="garage.preset.balanced">Balanced Spec</span>
        </button>
      </div>
  </div>

  <!-- Right Side Racer Showcase Dock: Under 3D Kart -->
  <div class="racer-showcase-dock">
    <div class="racer-active-pill">
      <span class="racer-active-dot"></span>
      <span class="racer-active-name" data-i18n="racer.luna">Luna Axolotl</span>
    </div>
    <div class="racer-capsule">
      ${i}
    </div>
  </div>

  <footer class="bottom-bar"><div class="prompts"></div><small data-i18n="credits.fonts"></small></footer>
</section>

<section class="screen screen-hud" data-screen="hud">
  <div class="boost-vignette"></div>
  <div class="hurt-vignette"></div>
  <div class="final-lap-vignette"></div>
  <div class="popups"></div>
  <div class="hud-top-left">
    <div class="hud-row">
      <div class="hud-place" data-place="6"><b data-slot="place">6th</b></div>
      <div class="hud-panel hud-lap"><span class="hud-lap-label" data-i18n="hud.lap"></span><b data-slot="lap">1<small>/3</small></b></div>
    </div>
    <div class="hud-score"><span data-i18n="hud.score"></span><b data-slot="score">0</b></div>
  </div>
  <div class="hud-top-center">
    <div class="hud-clock"><b data-slot="clock">0:00.00</b></div>
    <div class="hud-item" data-action="use-item" data-state="empty" data-item="none">
      <span class="hud-item-icon" data-slot="item-icon">${Y.candy}</span>
      <b class="hud-item-name" data-slot="item-label" data-i18n="hud.itemEmpty"></b>
      <kbd class="hud-item-key">E</kbd>
    </div>
  </div>
  <div class="hud-top-right">
    <ol class="hud-standings" data-slot="standings"></ol>
    <button class="hud-pause" data-action="pause" data-i18n-label="touch.pause">${Y.pause}</button>
  </div>
  <div class="hud-minimap" aria-hidden="true">
    <svg viewBox="0 0 100 100">
      <path class="minimap-border" d="${Z.candy.path}" />
      <path class="minimap-road" d="${Z.candy.path}" />
      <g class="minimap-pads">${n}</g>
      <circle class="minimap-start" cx="${Z.candy.start.u.toFixed(1)}" cy="${Z.candy.start.v.toFixed(1)}" r="3.2" />
      <g data-slot="minimap-dots"></g>
    </svg>
  </div>
  <div class="hud-speedo">
    <div class="hud-drift-badge" data-tier="0"><b data-slot="drift-badge"></b></div>
    <div class="hud-drift-meter"><i></i></div>
    <div class="hud-speed-readout"><b data-slot="speed">0</b><span data-i18n="hud.speed"></span></div>
    <div class="hud-speed-bar"><i></i></div>
  </div>
  <div class="hud-countdown"><b data-slot="countdown">3</b></div>
  <div class="hud-wrongway"><span data-i18n="hud.wrongWay"></span></div>
  <div class="banner"></div>
  <div class="hint"><span></span></div>
  <div class="touch">
    <div class="touch-stick"><i></i></div>
    <button class="touch-btn touch-dash" data-touch="dash"><span data-i18n="touch.dash"></span></button>
    <button class="touch-btn touch-jump" data-touch="jump"><span data-i18n="touch.jump"></span></button>
  </div>
</section>

<section class="screen screen-pause screen-modal" data-screen="pause">
  <div class="modal">
    <h2 class="modal-title" data-i18n="pause.title"></h2>
    <nav class="menu">
      <button data-nav class="btn btn-primary" data-action="resume"><span data-i18n="menu.continue"></span></button>
      <button data-nav class="btn" data-action="restart"><span data-i18n="menu.restart"></span></button>
      <button data-nav class="btn" data-action="settings"><span data-i18n="menu.settings"></span></button>
      <button data-nav class="btn" data-action="quit"><span data-i18n="menu.quit"></span></button>
    </nav>
  </div>
  <footer class="bottom-bar"><div class="prompts"></div></footer>
</section>

<section class="screen screen-settings screen-modal" data-screen="settings">
  <div class="modal modal-wide">
    <h2 class="modal-title" data-i18n="settings.title"></h2>
    <div class="settings-grid">
      <fieldset><legend data-i18n="settings.audio"></legend>
        ${e(`musicVolume`,`settings.music`,0,1,.05)}
        ${e(`sfxVolume`,`settings.sfx`,0,1,.05)}
        ${t(`muted`,`settings.mute`)}
      </fieldset>
      <fieldset><legend data-i18n="settings.controls"></legend>
        ${e(`sensitivity`,`settings.sensitivity`,.2,3,.1)}
        ${t(`invertY`,`settings.invertY`)}
      </fieldset>
      <fieldset><legend data-i18n="settings.display"></legend>
        <div class="row"><span data-i18n="settings.quality"></span><div class="seg" data-setting="quality">
          <button data-nav data-value="low" data-i18n="settings.quality.low"></button><button data-nav data-value="medium" data-i18n="settings.quality.medium"></button><button data-nav data-value="high" data-i18n="settings.quality.high"></button>
        </div></div>
        ${t(`reducedMotion`,`settings.reducedMotion`)}
        <div class="row"><span data-i18n="settings.language"></span><div class="seg" data-setting="locale">
          <button data-nav data-value="en" lang="en">English</button><button data-nav data-value="zh-CN" lang="zh-CN">简体中文</button><button data-nav data-value="tr" lang="tr">Türkçe</button>
        </div></div>
      </fieldset>
      <fieldset><legend data-i18n="settings.race"></legend>
        <div class="row"><span data-i18n="menu.track"></span><div class="seg" data-setting="map">
          <button data-nav data-value="candy" data-i18n="map.candy"></button><button data-nav data-value="forest" data-i18n="map.forest"></button><button data-nav data-value="beach" data-i18n="map.beach"></button><button data-nav data-value="frosthold" data-i18n="map.frosthold"></button><button data-nav data-value="ember" data-i18n="map.ember"></button><button data-nav data-value="skyway" data-i18n="map.skyway"></button><button data-nav data-value="noel" data-i18n="map.noel"></button>
        </div></div>
        <div class="row"><span data-i18n="menu.laps"></span><div class="seg" data-setting="laps">
          <button data-nav data-value="2">2</button><button data-nav data-value="3">3</button><button data-nav data-value="5">5</button><button data-nav data-value="7">7</button>
        </div></div>
      </fieldset>
    </div>
    <nav class="menu menu-row"><button data-nav class="btn" data-action="back"><span data-i18n="menu.back"></span></button></nav>
  </div>
  <footer class="bottom-bar"><div class="prompts"></div></footer>
</section>

<section class="screen screen-garage screen-modal" data-screen="garage">
  <div class="modal modal-wide garage-modal">
    <h2 class="modal-title" data-i18n="garage.title">3D GARAGE DYNO & KART TUNING</h2>
    <p class="vip-subtitle" data-i18n="garage.subtitle">Customize transmission ratio, cornering grip, and mini-turbo boost response for your kart.</p>
    <div class="garage-presets-grid" role="group" aria-label="Dyno Presets">
      <button data-nav type="button" class="garage-preset-btn" data-action="select-preset" data-preset="balanced" aria-pressed="true">
        <span>⚖️</span><strong data-i18n="garage.preset.balanced">Balanced Spec</strong>
      </button>
      <button data-nav type="button" class="garage-preset-btn" data-action="select-preset" data-preset="speed" aria-pressed="false">
        <span>🚀</span><strong data-i18n="garage.preset.speed">Apex Top-Speed</strong>
      </button>
      <button data-nav type="button" class="garage-preset-btn" data-action="select-preset" data-preset="drift" aria-pressed="false">
        <span>⚡</span><strong data-i18n="garage.preset.drift">Drift-Turbo Pro</strong>
      </button>
      <button data-nav type="button" class="garage-preset-btn" data-action="select-preset" data-preset="grip" aria-pressed="false">
        <span>🛞</span><strong data-i18n="garage.preset.grip">Featherweight Grip</strong>
      </button>
    </div>
    <div class="settings-grid">
      <fieldset><legend data-i18n="menu.garage">Dyno Parameters</legend>
        ${e(`garage_maxSpeed`,`garage.stat.speed`,24,50,1)}
        ${e(`garage_acceleration`,`garage.stat.accel`,14,42,1)}
        ${e(`garage_turnRate`,`garage.stat.handling`,1.2,3.2,.1)}
        ${e(`garage_boost1`,`garage.stat.drift`,.5,1.8,.1)}
      </fieldset>
    </div>
    <nav class="menu menu-row">
      <button data-nav type="button" class="btn" data-action="garage-reset"><span data-i18n="garage.reset">Reset Factory Spec</span></button>
      <button data-nav type="button" class="btn btn-primary" data-action="back"><span data-i18n="garage.apply">Apply & Return to Track</span></button>
    </nav>
  </div>
  <footer class="bottom-bar"><div class="prompts"></div></footer>
</section>

<section class="screen screen-leaderboard screen-modal" data-screen="leaderboard">
  <div class="modal">
    <h2 class="modal-title" data-i18n="leaderboard.title"></h2>
    <div class="board-head"><b>#</b><span></span><span data-i18n="leaderboard.time"></span><em data-i18n="leaderboard.score"></em></div>
    <ol class="board"></ol>
    <nav class="menu menu-row"><button data-nav class="btn" data-action="back"><span data-i18n="menu.back"></span></button></nav>
  </div>
  <footer class="bottom-bar"><div class="prompts"></div></footer>
</section>

<section class="screen screen-vip screen-modal" data-screen="vip">
  <div class="modal modal-wide vip-modal">
    <div class="vip-badge-pill" data-i18n="vip.trialBadge">7-DAY FREE TRIAL • CANCEL ANYTIME</div>
    <h2 class="modal-title" data-i18n="vip.title">LOLLY LAP CLUB — PRO RACING PASS</h2>
    <p class="vip-subtitle" data-i18n="vip.subtitle">Unlock all 7 championship circuits, all 8 critter drivers, Pro Garage Dyno setups, and endurance lap modes.</p>
    <p class="vip-demo-notice" data-i18n="vip.demoNotice">Includes a 7-Day Free Trial. Cancel anytime in your account settings.</p>
    <div class="vip-plans-grid" role="radiogroup" aria-label="Subscription Plans">
      <button data-nav type="button" class="vip-plan-card" data-action="select-vip-plan" data-plan="monthly" aria-pressed="false">
        <span class="vip-plan-period" data-i18n="vip.plan.monthly">1 Month</span>
        <strong class="vip-plan-price" data-i18n="vip.plan.monthly.price">$4.99 / mo</strong>
        <small class="vip-plan-sub" data-i18n="vip.plan.monthly.sub">7 days free, then $4.99 billed monthly</small>
      </button>
      <button data-nav type="button" class="vip-plan-card" data-action="select-vip-plan" data-plan="quarterly" aria-pressed="false">
        <span class="vip-plan-ribbon" data-i18n="vip.save10">SAVE 10%</span>
        <span class="vip-plan-period" data-i18n="vip.plan.quarterly">3 Months</span>
        <strong class="vip-plan-price" data-i18n="vip.plan.quarterly.price">$4.49 / mo</strong>
        <small class="vip-plan-sub" data-i18n="vip.plan.quarterly.sub">7 days free, then $13.47 ($4.49 × 3) every 3 months</small>
      </button>
      <button data-nav type="button" class="vip-plan-card vip-plan-featured" data-action="select-vip-plan" data-plan="annual" aria-pressed="true">
        <span class="vip-plan-ribbon vip-ribbon-gold" data-i18n="vip.bestValue">BEST VALUE • SAVE 20%</span>
        <span class="vip-plan-period" data-i18n="vip.plan.annual">12 Months</span>
        <strong class="vip-plan-price" data-i18n="vip.plan.annual.price">$3.99 / mo</strong>
        <small class="vip-plan-sub" data-i18n="vip.plan.annual.sub">7 days free, then $47.88 ($3.99 × 12) billed annually</small>
      </button>
    </div>
    <nav class="menu menu-row">
      <button data-nav type="button" class="btn" data-action="restore-vip"><span data-i18n="vip.restore">Restore Purchases</span></button>
      <button data-nav type="button" class="btn btn-primary" data-action="back"><span data-i18n="vip.continueDemo">Back to Circuits</span></button>
    </nav>
  </div>
  <footer class="bottom-bar"><div class="prompts"></div></footer>
</section>

<section class="screen screen-results screen-modal" data-screen="results">
  <div class="modal modal-results">
    <div class="results-stars">${`<span class="star">${Y.star}</span>`.repeat(3)}</div>
    <h2 class="results-title modal-title"></h2>
    <div class="results-best" data-i18n="results.newBest"></div>
    <ol class="results-standings"></ol>
    <dl class="results-table">
      <div><dt data-i18n="results.place"></dt><dd class="r-place"></dd><dd class="r-place-score"></dd></div>
      <div><dt data-i18n="results.time"></dt><dd class="r-time"></dd><dd></dd></div>
      <div><dt data-i18n="results.bestLap"></dt><dd class="r-best-lap"></dd><dd></dd></div>
      <div><dt data-i18n="results.driftBonus"></dt><dd class="r-drift-count"></dd><dd class="r-drift-bonus"></dd></div>
      <div><dt data-i18n="results.hitBonus"></dt><dd class="r-hit-count"></dd><dd class="r-hit-bonus"></dd></div>
      <div class="r-total-row"><dt data-i18n="results.total"></dt><dd></dd><dd class="r-total"></dd></div>
    </dl>
    <div class="results-save">
      <input data-nav class="results-name" type="text" maxlength="16" autocomplete="off" spellcheck="false" data-i18n-placeholder="results.name">
      <button data-nav class="btn btn-small" data-action="save-score"><span data-i18n="results.save"></span></button>
      <span class="results-saved" data-i18n="results.saved"></span>
      <span class="results-rank"></span>
    </div>
    <nav class="menu menu-row">
      <button data-nav class="btn btn-primary" data-action="restart"><span data-i18n="results.retry"></span></button>
      <button data-nav class="btn" data-action="garage"><span data-i18n="menu.garage">Garage & Dyno</span></button>
      <button data-nav class="btn" data-action="quit"><span data-i18n="results.title"></span></button>
    </nav>
  </div>
</section>`}},ze=`modulepreload`,Be=function(e,t){return new URL(e,t).href},Ve={},$=function(e,t,n){let r=Promise.resolve();if(t&&t.length>0){let e=document.getElementsByTagName(`link`),i=document.querySelector(`meta[property=csp-nonce]`),a=i?.nonce||i?.getAttribute(`nonce`);function o(e){return Promise.all(e.map(e=>Promise.resolve(e).then(e=>({status:`fulfilled`,value:e}),e=>({status:`rejected`,reason:e}))))}function s(e){return import.meta.resolve?import.meta.resolve(e):new URL(e,import.meta.url).href}r=o(t.map(t=>{if(t=Be(t,n),t=s(t),t in Ve)return;Ve[t]=!0;let r=t.endsWith(`.css`);for(let n=e.length-1;n>=0;n--){let i=e[n];if(i.href===t&&(!r||i.rel===`stylesheet`))return}let i=document.createElement(`link`);if(i.rel=r?`stylesheet`:ze,r||(i.as=`script`),i.crossOrigin=``,i.href=t,a&&i.setAttribute(`nonce`,a),document.head.appendChild(i),r)return new Promise((e,n)=>{i.addEventListener(`load`,e),i.addEventListener(`error`,()=>n(Error(`Unable to preload CSS for ${t}`)))})}).filter(e=>e!==void 0))}function i(e){let t=new Event(`vite:preloadError`,{cancelable:!0});if(t.payload=e,window.dispatchEvent(t),!t.defaultPrevented)throw e}return r.then(t=>{for(let e of t||[])e.status===`rejected`&&i(e.reason);return e().catch(i)})};async function He(){let e=document.querySelector(`#game`),n=Ue(m)===null,r=new ee,i=new URLSearchParams(window.location.search),a=i.get(`lang`),o=a===`en`||a===`tr`||a===`zh-CN`?a:null,l=i.get(`demo`)===`1`,u=new c(o||(l?`en`:s(r.data.locale,navigator.languages))),d=new f(e),h=new t,g,_=0,v=e=>{d.sensitivity=e.sensitivity,d.invertY=e.invertY,h.setVolumes(e.musicVolume,e.sfxVolume,e.muted),g&&(g.reducedMotion=e.reducedMotion)},y=(e,t={})=>{try{window.webkit?.messageHandlers?.lollyBridge?.postMessage({type:e,...t})}catch{}},b=e=>{g&&(h.unlock(),h.startMusic(),g.start(e),C.show(`hud`),C.updateHud(g.hud()),k.resetAccumulator(),d.lockPointer(),y(`raceStart`,{map:r.data.map,laps:r.data.laps}))},x=()=>{g?.mode===`playing`&&(g.pause(),C.show(`pause`),d.unlockPointer())},S=()=>{g?.mode===`paused`&&(g.resume(),C.show(`hud`),k.resetAccumulator(),d.lockPointer())},C=new Re(u,r,h,d,{play:()=>b(!r.data.tutorialDone),restart:()=>b(!1),resume:S,quit:()=>{g?.toTitle(),C.show(`title`),d.unlockPointer()},settings:e=>{let t=e.quality!==void 0&&e.quality!==r.data.quality,n=e.map!==void 0&&e.map!==r.data.map,i=e.laps!==void 0&&e.laps!==r.data.laps;r.update(e),v(r.data),e.locale&&u.set(e.locale),t&&g?.setQuality(r.data.quality),n&&e.map&&g?.setMap(e.map),i&&e.laps&&g?.setLaps(e.laps)},selectMap:e=>{r.update({map:e}),g?.setMap(e)},selectLaps:e=>{r.update({laps:e}),g?.setLaps(e)},selectRacer:e=>g?.selectCritter(e)});C.show(`boot`),v(r.data);let w=0,T=e=>e.then(e=>(C.setBootProgress(.1+ ++w/4*.9),e));C.setBootProgress(.1);let[{Game:E},{Renderer:D,suggestQuality:ne},re]=await Promise.all([T($(()=>import(`./game-DVHg2UF1.js`),__vite__mapDeps([0,1]),import.meta.url)),T($(()=>import(`./renderer-BRPUaEWJ.js`),__vite__mapDeps([2,1]),import.meta.url)),T($(()=>import(`./physics-D5W6iAvK.js`),__vite__mapDeps([3,1]),import.meta.url)),T(document.fonts.ready)]);await re.initPhysics(),n&&(r.update({quality:ne()}),C.refreshSettings()),g=new E(new D(e,r.data.quality),d,h,{popup:(e,t,n)=>{C.popup(e,t,n),y(`popup`,{text:e,kind:n})},hurt:()=>{C.hurt(),y(`hurt`,{})},hint:e=>C.hint(e),banner:e=>C.banner(e),tutorialDone:()=>r.update({tutorialDone:!0}),end:e=>{d.unlockPointer(),y(`raceEnd`,{place:e.race.place,clock:e.race.clock,bestLap:e.race.bestLap,driftBoosts:e.race.driftBoosts,hits:e.race.hits,score:e.race.score,map:r.data.map,laps:r.data.laps}),window.setTimeout(()=>C.showResults(e),e.race.place<=3?1300:900)}},r.data.map,r.data.laps),g.reducedMotion=r.data.reducedMotion;let O=g,k=new p({step:e=>O.step(e),render:(e,t)=>{d.update(),d.consume(`pause`)&&performance.now()-_>300&&(O.mode===`playing`?x():O.mode===`paused`&&C.screen===`pause`&&S()),C.frame(t),k.paused=O.mode===`paused`,O.render(e,t),(O.mode===`playing`||O.mode===`ended`)&&C.updateHud(O.hud())}});k.start(),document.addEventListener(`pointerlockchange`,()=>{!document.pointerLockElement&&O.mode===`playing`&&d.method===`keyboard`&&(_=performance.now(),x())}),document.addEventListener(`visibilitychange`,()=>{document.hidden&&x()}),window.addEventListener(`game:pause`,x),window.addEventListener(`game:start`,()=>b(!1)),e.addEventListener(`click`,()=>{O.mode===`playing`&&d.lockPointer()}),new te(document.getElementById(`ui`),d,()=>O.mode===`playing`);let A=new URLSearchParams(window.location.search),j=A.get(`map`);j&&(r.update({map:j}),O.setMap(j));let M=Number(A.get(`laps`));M>0&&(r.update({laps:M}),O.setLaps(M));let N=A.get(`racer`);if(N!==null){let e=Number(N);isNaN(e)||O.selectCritter(e)}A.has(`race`)||A.has(`start`)||A.has(`play`)||A.has(`autostart`)?window.setTimeout(()=>b(!1),220):window.setTimeout(()=>C.show(`title`),250),window.__game={game:O,ui:C,input:d,save:r}}function Ue(e){try{return localStorage.getItem(e)}catch{return null}}He().catch(e=>{console.error(e);let t=document.getElementById(`ui`);t&&(t.innerHTML=`<div class="fatal">Failed to start: ${String(e?.message??e).replace(/[<>&]/g,``)}<br><button style="pointer-events:auto" onclick="location.reload()">Retry</button></div>`)});export{T as _,de as a,j as c,F as d,ie as f,re as g,k as h,K as i,ne as l,se as m,Le as n,H as o,O as p,G as r,A as s,fe as t,N as u};