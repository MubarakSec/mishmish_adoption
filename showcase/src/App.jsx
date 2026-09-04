import { useState, useEffect, useRef } from 'react'

const FILES = [
  { id:'main', path:'lib/main.dart', lines:27, icon:'🎯', color:'#FF6B6B', desc:'نقطة البداية — يحدد الاتجاه RTL والثيم', fns:[
    {n:'main()', d:'يهيئ التطبيق', c:'WidgetsFlutterBinding.ensureInitialized()'},
    {n:'KittenApp', d:'يغلف التطبيق بـ Directionality RTL', c:'MaterialApp + Theme'},
  ]},
  { id:'api', path:'lib/services/api_service.dart', lines:123, icon:'🔌', color:'#4ECDC4', desc:'كل اتصال السيرفر من مكان واحد', fns:[
    {n:'register()', d:'POST /api/register', c:'name, email, password'},
    {n:'login()', d:'POST /api/login → token', c:'saves token + user in prefs'},
    {n:'getKittens()', d:'GET /api/kittens → List', c:'no auth needed'},
    {n:'toggleFavorite()', d:'POST /api/favorites/:id', c:'needs Bearer token'},
    {n:'forgot → verify → reset', d:'3 calls OTP flow', c:'code shown for demo'},
  ]},
  { id:'splash', path:'lib/screens/splash_screen.dart', lines:57, icon:'✨', color:'#FFD93D', desc:'يقرر أين يذهب المستخدم بعد 3 ثواني', fns:[
    {n:'_checkState()', d:'delay 3s → check prefs', c:'onboarding_done? → Onboarding : token? → Home : Login'},
  ]},
  { id:'onboarding', path:'lib/screens/onboarding/onboarding_screen.dart', lines:99, icon:'👋', color:'#A78BFA', desc:'3 صفحات PageView + حفظ الحالة', fns:[
    {n:'PageView.builder', d:'3 slides with emoji', c:'indicator dots animate'},
    {n:'_completeOnboarding()', d:'prefs.setBool(onboarding_done, true)', c:'→ Login'},
  ]},
  { id:'login', path:'lib/screens/auth/login_screen.dart', lines:110, icon:'🔐', color:'#FF6B6B', desc:'دخول + إظهار/إخفاء الباسورد', fns:[
    {n:'_login()', d:'validate → ApiService.login', c:'setToken + saveUser → Home'},
    {n:'validator', d:'email required', c:'password required'},
  ]},
  { id:'signup', path:'lib/screens/auth/signup_screen.dart', lines:124, icon:'📝', color:'#F472B6', desc:'إنشاء حساب + تأكيد كلمة المرور', fns:[
    {n:'_signup()', d:'ApiService.register', c:'token → Login'},
  ]},
  { id:'forgot', path:'lib/screens/auth/forgot→verify→reset', lines:255, icon:'📧', color:'#60A5FA', desc:'رحلة كاملة: email → code → new password', fns:[
    {n:'forgotPassword()', d:'POST /forgot-password', c:'BE returns code (demo)'},
    {n:'verifyCode()', d:'POST /verify-code', c:'check DB token'},
    {n:'resetPassword()', d:'POST /reset-password', c:'hash new password'},
  ]},
  { id:'home', path:'lib/screens/home/home_tab.dart', lines:104, icon:'🏠', color:'#34D399', desc:'Grid 2 أعمدة من API', fns:[
    {n:'_fetch()', d:'ApiService.getKittens()', c:'map → Kitten.fromJson'},
    {n:'GridView 2-col', d:'KittenCard → Detail', c:'image from cataas.com'},
  ]},
  { id:'detail', path:'lib/screens/home/kitten_detail_screen.dart', lines:132, icon:'🐱', color:'#FF6B6B', desc:'صورة كبيرة + تبني + مفضلة', fns:[
    {n:'_toggleFavorite()', d:'POST favorite', c:'snackbar ❤️'},
    {n:'_adopt()', d:'AlertDialog 🎉', c:'مبروك تبنيت مشمش!'},
  ]},
  { id:'fav', path:'lib/screens/favorites/favorites_tab.dart', lines:93, icon:'❤️', color:'#EF4444', desc:'قائمة من /api/favorites (محمية)', fns:[
    {n:'getFavorites()', d:'with token', c:'trailing ♥ to remove'},
  ]},
  { id:'profile', path:'lib/screens/profile/profile_tab.dart', lines:91, icon:'👤', color:'#636E72', desc:'يعرض الاسم + تسجيل خروج', fns:[
    {n:'_logout()', d:'POST /logout + clearToken', c:'→ Login + remove prefs'},
  ]},
  // laravel
  { id:'authCtrl', path:'mishmish-api/app/Http/Controllers/Api/AuthController.php', lines:120, icon:'⚙️', color:'#FF6B6B', desc:'كل منطق الدخول وكلمة المرور', fns:[
    {n:'register', d:'validate + Hash::make + createToken', c:'201 + token'},
    {n:'login', d:'Hash::check', c:'401 if wrong'},
    {n:'forgot/verify/reset', d:'Str::random(6) in password_reset_tokens', c:'demo: return code'},
  ]},
  { id:'kittenCtrl', path:'mishmish-api/app/Http/Controllers/Api/KittenController.php', lines:23, icon:'📦', color:'#4ECDC4', desc:'بس ترجع القطط', fns:[
    {n:'index()', d:'Kitten::all()', c:'GET /api/kittens'},
  ]},
  { id:'routes', path:'mishmish-api/routes/api.php', lines:24, icon:'🛣️', color:'#FFD93D', desc:'10 routes — 5 عامة + 3 محمية', fns:[
    {n:'public', d:'/register /login /kittens', c:'no middleware'},
    {n:'auth:sanctum', d:'/logout /favorites', c:'Bearer required'},
  ]},
]

const ENDPOINTS = [
  {m:'POST', p:'/api/register', a:'public', d:'إنشاء حساب', ex:'{name, email, password}'},
  {m:'POST', p:'/api/login', a:'public', d:'دخول → token', ex:'{email, password}'},
  {m:'POST', p:'/api/forgot-password', a:'public', d:'إرسال OTP', ex:'{email} → {code}'},
  {m:'POST', p:'/api/verify-code', a:'public', d:'تحقق الرمز', ex:'{email, code}'},
  {m:'POST', p:'/api/reset-password', a:'public', d:'كلمة جديدة', ex:'{email, password}'},
  {m:'GET', p:'/api/kittens', a:'public', d:'كل القطط (12)', ex:'→ Kitten[]'},
  {m:'GET', p:'/api/kittens/{id}', a:'public', d:'قط واحد', ex:'→ Kitten'},
  {m:'GET', p:'/api/favorites', a:'auth', d:'مفضلتي', ex:'→ Favorite[]'},
  {m:'POST', p:'/api/favorites/{id}', a:'auth', d:'toggle ♥', ex:'→ {is_favorite}'},
  {m:'POST', p:'/api/logout', a:'auth', d:'خروج', ex:'delete token'},
]

export default function App(){
  const [active, setActive] = useState('api')
  const [phoneIdx, setPhoneIdx] = useState(0)
  const [copied, setCopied] = useState('')
  const [apiLive, setApiLive] = useState(null)
  const [trying, setTrying] = useState(false)
  const activeFile = FILES.find(f=>f.id===active)

  useEffect(()=>{
    const id=setInterval(()=> setPhoneIdx(i=> (i+1)%7), 2200)
    return ()=>clearInterval(id)
  },[])

  const tryApi = async()=>{
    setTrying(true)
    try{ const r=await fetch('http://localhost:8000/api/kittens'); const j=await r.json(); setApiLive(j.slice(0,2)) }catch{ setApiLive('offline')}
    setTrying(false)
  }

  const copy = (t,k)=>{ navigator.clipboard.writeText(t); setCopied(k); setTimeout(()=>setCopied(''),1500)}

  return (
    <div style={{position:'relative'}}>
      <div className="paws" />
      {/* falling cats */}
      <div style={{position:'fixed',inset:0,pointerEvents:'none',overflow:'hidden',zIndex:0}}>
        {[...Array(8)].map((_,i)=>(
          <div key={i} style={{position:'absolute', left:`${8+i*11}%`, top:'-10vh', fontSize:18+i%2*6, animation:`drift ${9+i*1.2}s linear infinite`, animationDelay:`${i*0.9}s`}}>🐾</div>
        ))}
      </div>

      {/* NAV */}
      <nav className="glass" style={{position:'sticky',top:14, zIndex:50, margin:'14px auto', maxWidth:1100, borderRadius:999, padding:'10px 16px', display:'flex', alignItems:'center', gap:12, justifyContent:'space-between'}}>
        <div style={{display:'flex',alignItems:'center',gap:10, fontWeight:800, fontSize:15}}>
          <span style={{width:32,height:32,borderRadius:999,background:'#FF6B6B',display:'grid',placeItems:'center',color:'white'}}>🐱</span>
          مشمش <span style={{opacity:.5,fontWeight:400}}>/ showcase</span>
        </div>
        <div style={{display:'flex',gap:6, flexWrap:'wrap'}}>
          {['flow','run','files','api','screens'].map(id=>(
            <a key={id} href={`#${id}`} style={{padding:'7px 12px', borderRadius:999, background:'white', border:'1px solid rgba(0,0,0,.06)', fontSize:13, fontWeight:600}}>{id}</a>
          ))}
        </div>
        <a href="#run" className="btn btn-pink" style={{padding:'8px 14px', fontSize:13}}>شغّل المشروع →</a>
      </nav>

      {/* HERO */}
      <section style={{maxWidth:1100, margin:'18px auto', padding:'0 16px', display:'grid', gridTemplateColumns:'1.1fr .9fr', gap:18, alignItems:'center'}}>
        <div>
          <div className="pill" style={{background:'white', border:'1px solid rgba(0,0,0,.06)'}}>
            <span style={{width:8,height:8,borderRadius:999,background:'#22c55e', display:'inline-block', animation:'pulse 1.5s infinite'}} /> API live · 12 kittens · Flutter + Laravel
          </div>
          <h1 style={{fontSize:'clamp(32px,5vw,54px)', lineHeight:.95, marginTop:14, letterSpacing:'-0.03em'}}>
            تطبيق قطط<br/>
            <span style={{background:'linear-gradient(90deg,#FF6B6B,#FF8A5B)', WebkitBackgroundClip:'text', color:'transparent'}}>يجيب الدرجة</span><br/>
            <span className="ar" style={{fontSize:'0.6em', opacity:.9}}>مشمش 🐱</span>
          </h1>
          <p style={{marginTop:12, color:'#636E72', fontSize:16, lineHeight:1.6, maxWidth:540}}>
            مشروع موبايل كامل: splash + onboarding + auth + OTP + bottom nav + مفضلة — كل البيانات من <span className="mono" style={{background:'white',padding:'2px 6px',borderRadius:6,border:'1px solid #eee'}}>Laravel API + MySQL</span> (هنا SQLite للعرض). بدون تعقيد، شغال 100%.
          </p>
          <div style={{display:'flex', gap:10, marginTop:18, flexWrap:'wrap'}}>
            <a href="#files" className="btn btn-pink">استكشف الملفات 🗂️</a>
            <a href="#screens" className="btn btn-ghost">شوف الشاشات 📱</a>
          </div>
          <div style={{display:'flex', gap:10, marginTop:18, flexWrap:'wrap'}}>
            {[{k:'1356',l:'lines Flutter'},{k:'624',l:'lines Laravel'},{k:'12',l:'kittens'},{k:'10',l:'endpoints'}].map(s=>(
              <div key={s.l} className="card" style={{padding:'10px 14px', minWidth:110}}>
                <div style={{fontSize:22, fontWeight:800}}>{s.k}</div><div style={{fontSize:12, opacity:.6}}>{s.l}</div>
              </div>
            ))}
          </div>
        </div>

        <div style={{display:'grid', placeItems:'center'}}>
          <div style={{position:'relative'}}>
            <div style={{position:'absolute', inset:-30, background:'radial-gradient(circle at 50% 40%, #FF6B6B22, transparent 70%)', borderRadius:40}} />
            <div className="phone" style={{animation:'float 4s ease-in-out infinite'}}>
              <div className="phone-notch" />
              <div className="phone-screen">
                {/* mini app header */}
                <div style={{background:'#FF6B6B', color:'white', padding:'28px 14px 10px', display:'flex', justifyContent:'space-between', alignItems:'center'}}>
                  <span style={{fontWeight:800}}>🐱 مشمش</span><span style={{opacity:.9}}>☰</span>
                </div>
                <PhonePreview idx={phoneIdx} />
                <div style={{marginTop:'auto', display:'flex', justifyContent:'space-around', padding:'8px 0', borderTop:'1px solid #eee', fontSize:11}}>
                  <span style={{color: phoneIdx<2 ? '#FF6B6B':'#999'}}>🏠 الرئيسية</span>
                  <span style={{color: phoneIdx===5 ? '#FF6B6B':'#999'}}>❤️ المفضلة</span>
                  <span style={{color: phoneIdx===6 ? '#FF6B6B':'#999'}}>👤 حسابي</span>
                </div>
              </div>
            </div>
            <div className="card" style={{position:'absolute', left:-18, top:20, padding:'8px 10px', display:'flex', gap:8, alignItems:'center', fontSize:12, fontWeight:700, transform:'rotate(-2deg)'}}>
              <span style={{width:28,height:28, borderRadius:999, background:'#FFF0F0', display:'grid', placeItems:'center'}}>⚡</span> Splash 3s
            </div>
            <div className="card" style={{position:'absolute', right:-16, bottom:30, padding:'8px 10px', display:'flex', gap:8, alignItems:'center', fontSize:12, fontWeight:700, transform:'rotate(2deg)'}}>
              🎉 تم التبني!<span style={{opacity:.6}}>mishmish</span>
            </div>
          </div>
        </div>
      </section>

      {/* ARCH */}
      <section id="flow" style={{maxWidth:1100, margin:'28px auto', padding:'0 16px'}}>
        <div className="card" style={{padding:18, overflow:'hidden'}}>
          <div className="tag">architecture — tap to pulse</div>
          <ArchDiagram />
          <div style={{display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:12, marginTop:14}}>
            {[
              {t:'Flutter', d:'http + shared_preferences + launcher_icons', c:'#FF6B6B'},
              {t:'Laravel API', d:'Sanctum tokens + Validation + 10 routes', c:'#4ECDC4'},
              {t:'DB SQLite', d:'users / kittens / favorites / tokens', c:'#FFD93D'},
            ].map(b=>(
              <div key={b.t} style={{background:`${b.c}14`, border:`1px solid ${b.c}30`, borderRadius:16, padding:14}}>
                <div style={{fontWeight:800}}>{b.t}</div><div style={{fontSize:13, opacity:.7}}>{b.d}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* RUN */}
      <section id="run" style={{maxWidth:1100, margin:'18px auto', padding:'0 16px', display:'grid', gridTemplateColumns:'1fr 1fr', gap:14}}>
        <Terminal title="Backend — Laravel :8000" copyText={`cd mishmish-api\nphp artisan migrate:fresh --seed\nphp artisan serve --host=0.0.0.0 --port=8000`} onCopy={copy} copied={copied} id="be" lines={[
          '$ php artisan migrate:fresh --seed',
          '  kittens: 12 inserted ✓',
          '$ php artisan serve --host=0.0.0.0 --port=8000',
          '  → http://localhost:8000/api/kittens',
        ]} />
        <Terminal title="Frontend — Flutter" copyText={`cd mishmish\nflutter pub get\nflutter run -d chrome\n# phone → change baseUrl to 192.168.x.x`} onCopy={copy} copied={copied} id="fe" lines={[
          '$ flutter pub get  ✓',
          '$ flutter run -d chrome',
          '  API: http://10.0.2.2:8000/api (emulator)',
          '  real device → use your IP',
        ]} />
      </section>

      {/* FILES EXPLORER */}
      <section id="files" style={{maxWidth:1100, margin:'18px auto', padding:'0 16px'}}>
        <div style={{display:'flex', alignItems:'end', justifyContent:'space-between', gap:12, flexWrap:'wrap'}}>
          <h2 style={{fontSize:28, letterSpacing:'-0.02em'}}>File Explorer <span style={{opacity:.5, fontWeight:400}}>— اضغط أي ملف وشوف وظيفته</span></h2>
          <span className="mono" style={{fontSize:12, opacity:.6}}>{FILES.length} files · interactive</span>
        </div>
        <div className="card" style={{marginTop:12, display:'grid', gridTemplateColumns:'320px 1fr', minHeight:520, overflow:'hidden'}}>
          {/* sidebar */}
          <div style={{borderRight:'1px solid #eee', background:'#FAFAF9', overflow:'auto'}}>
            <div style={{padding:'12px 12px 8px', fontSize:11, letterSpacing:'.08em', opacity:.5, fontWeight:800}}>EXPLORER</div>
            <div style={{padding:'6px 8px', fontSize:12, opacity:.6}}>📁 mishmish/lib</div>
            {FILES.map(f=>(
              <button key={f.id} onClick={()=>setActive(f.id)} style={{width:'100%', textAlign:'left', display:'flex', gap:10, alignItems:'center', padding:'10px 12px', background: active===f.id ? 'white':'transparent', borderLeft: active===f.id ? `3px solid ${f.color}` : '3px solid transparent', borderTop:'none', borderRight:'none', borderBottom:'1px solid #f0f0f0'}}>
                <span style={{width:28,height:28, borderRadius:8, background:`${f.color}18`, display:'grid', placeItems:'center', fontSize:14}}>{f.icon}</span>
                <span style={{flex:1, minWidth:0}}>
                  <div className="mono" style={{fontSize:11, whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis', fontWeight:700}}>{f.path.split('/').pop()}</div>
                  <div style={{fontSize:11, opacity:.6}}>{f.lines} lines</div>
                </span>
                <span style={{fontSize:10, opacity:.4}}>›</span>
              </button>
            ))}
          </div>
          {/* detail */}
          <div style={{padding:18, overflow:'auto', background:'white'}}>
            <div style={{display:'flex', gap:10, alignItems:'center', flexWrap:'wrap'}}>
              <span style={{width:36,height:36, borderRadius:12, background:`${activeFile.color}18`, display:'grid', placeItems:'center', fontSize:18}}>{activeFile.icon}</span>
              <div>
                <div className="mono" style={{fontWeight:800, fontSize:13}}>{activeFile.path}</div>
                <div style={{fontSize:13, opacity:.7}}>{activeFile.desc} · <span className="mono">{activeFile.lines} lines</span></div>
              </div>
              <span className="pill" style={{marginLeft:'auto', background:`${activeFile.color}18`, color:activeFile.color, border:`1px solid ${activeFile.color}30`}}>{activeFile.fns.length} functions</span>
            </div>

            <div style={{marginTop:14, display:'grid', gap:10}}>
              {activeFile.fns.map(fn=>(
                <div key={fn.n} className="card" style={{padding:12, display:'grid', gridTemplateColumns:'1fr auto', gap:10, alignItems:'center'}}>
                  <div>
                    <div className="mono" style={{fontWeight:800, fontSize:13}}>{fn.n} <span style={{fontWeight:400, opacity:.6}}>— {fn.d}</span></div>
                    <div className="mono" style={{marginTop:6, background:'#0B0B0B', color:'#A7F3D0', padding:'7px 10px', borderRadius:10, fontSize:11, overflow:'auto'}}>{fn.c}</div>
                  </div>
                  <div style={{width:44,height:44, borderRadius:12, background:`${activeFile.color}12`, display:'grid', placeItems:'center', fontSize:18}}>⚡</div>
                </div>
              ))}
            </div>

            <div style={{marginTop:14, display:'flex', gap:8, flexWrap:'wrap'}}>
              <span className="tag">visual</span>
              <span style={{fontSize:12, opacity:.6}}>كل دالة هنا مربوطة بـ UI أو API حقيقي — جرّب الـ API playground تحت.</span>
            </div>
          </div>
        </div>
      </section>

      {/* SCREENS */}
      <section id="screens" style={{maxWidth:1100, margin:'18px auto', padding:'0 16px'}}>
        <div className="card" style={{padding:18}}>
          <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', flexWrap:'wrap', gap:10}}>
            <h2 style={{fontSize:24}}>Screen Flow — الرحلة الكاملة</h2>
            <div style={{display:'flex', gap:6}}>
              {[0,1,2,3,4,5,6].map(i=>(
                <button key={i} onClick={()=>setPhoneIdx(i)} style={{width:10,height:10,borderRadius:999, border:'none', background: phoneIdx===i ? '#FF6B6B' : '#E5E7EB'}} />
              ))}
            </div>
          </div>
          <div style={{marginTop:14, display:'grid', gridTemplateColumns:'300px 1fr', gap:16, alignItems:'center'}}>
            <div style={{display:'grid', placeItems:'center'}}>
              <div className="phone" style={{width:280, height:560}}>
                <div className="phone-notch" />
                <div className="phone-screen"><PhonePreview idx={phoneIdx} large /></div>
              </div>
            </div>
            <div>
              <FlowSteps idx={phoneIdx} setIdx={setPhoneIdx} />
              <div style={{marginTop:12, display:'flex', gap:8}}>
                <button className="btn btn-ghost" onClick={()=> setPhoneIdx(i=> (i+6)%7)}>‹ السابق</button>
                <button className="btn btn-pink" onClick={()=> setPhoneIdx(i=> (i+1)%7)}>التالي ›</button>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* API */}
      <section id="api" style={{maxWidth:1100, margin:'18px auto', padding:'0 16px'}}>
        <div className="card" style={{padding:18}}>
          <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', flexWrap:'wrap', gap:10}}>
            <h2 style={{fontSize:24}}>API Playground</h2>
            <button className="btn btn-pink" onClick={tryApi} disabled={trying}>{trying ? '... يجرب' : 'جرّب GET /kittens حقيقي →'}</button>
          </div>
          <div style={{display:'grid', gridTemplateColumns:'1.1fr .9fr', gap:14, marginTop:14}}>
            <div style={{display:'grid', gap:8}}>
              {ENDPOINTS.map(e=>(
                <div key={e.p} style={{display:'flex', gap:10, alignItems:'center', padding:'10px 12px', borderRadius:14, background: e.a==='auth' ? '#FFF7ED' : 'white', border:'1px solid #eee'}}>
                  <span className="mono" style={{fontSize:11, fontWeight:800, padding:'4px 8px', borderRadius:999, background: e.m==='GET' ? '#DCFCE7' : e.m==='POST' ? '#DBEAFE' : '#FEE2E2', color: e.m==='GET' ? '#166534' : '#1E40AF'}}>{e.m}</span>
                  <span className="mono" style={{fontSize:12, fontWeight:700}}>{e.p}</span>
                  <span style={{marginLeft:'auto', fontSize:12, padding:'3px 8px', borderRadius:999, background: e.a==='auth' ? '#FF6B6B' : '#E5E7EB', color: e.a==='auth' ? 'white':'#374151'}}>{e.a==='auth'?'🔒 auth':'🌍 public'}</span>
                </div>
              ))}
            </div>
            <div className="card" style={{padding:14, background:'#0B0B0B', color:'#E5E7EB', overflow:'auto'}}>
              <div className="mono" style={{fontSize:11, opacity:.6}}>RESPONSE — {apiLive ? (Array.isArray(apiLive)? `${apiLive.length} items` : apiLive) : 'اضغط "جرّب" فوق'}</div>
              <pre className="mono" style={{marginTop:8, fontSize:11, whiteSpace:'pre-wrap', wordBreak:'break-word', lineHeight:1.5}}>
{apiLive===null ? `// اضغط الزر وشوف بيانات حقيقية من Laravel
// http://localhost:8000/api/kittens
` : apiLive==='offline' ? `// السيرفر غير شغال
// شغّله: php artisan serve` : JSON.stringify(apiLive, null, 2)}
              </pre>
              <div style={{marginTop:10, display:'flex', gap:8, flexWrap:'wrap'}}>
                {ENDPOINTS.slice(0,3).map(e=>(
                  <span key={e.p} className="mono" style={{fontSize:10, background:'#1F2937', padding:'6px 8px', borderRadius:8}}>{e.ex}</span>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* DATA MODEL */}
      <section style={{maxWidth:1100, margin:'18px auto', padding:'0 16px', display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:12}}>
        {[
          {t:'users', c:'#FF6B6B', rows:['id','name','email','password (hashed)','created_at']},
          {t:'kittens', c:'#4ECDC4', rows:['id','name (ar)','breed','age','description','price','image_url']},
          {t:'favorites', c:'#FFD93D', rows:['id','user_id → users','kitten_id → kittens','unique(user,kitten)']},
        ].map(tbl=>(
          <div key={tbl.t} className="card" style={{padding:14, borderTop:`3px solid ${tbl.c}`}}>
            <div className="mono" style={{fontWeight:800}}>{tbl.t}</div>
            <div style={{marginTop:8, display:'grid', gap:6}}>
              {tbl.rows.map(r=>(
                <div key={r} style={{display:'flex', gap:8, alignItems:'center', fontSize:12, background:'#FAFAF9', padding:'7px 8px', borderRadius:10, border:'1px solid #eee'}}>
                  <span style={{width:6,height:6,borderRadius:999,background:tbl.c}} />{r}
                </div>
              ))}
            </div>
          </div>
        ))}
      </section>

      <footer style={{maxWidth:1100, margin:'18px auto 40px', padding:'0 16px'}}>
        <div className="card" style={{padding:16, display:'flex', justifyContent:'space-between', alignItems:'center', flexWrap:'wrap', gap:10}}>
          <span style={{fontWeight:700}}>🐱 مشمش — مشروع موبايل نهائي</span>
          <span className="mono" style={{fontSize:12, opacity:.6}}>Flutter • Laravel • SQLite · 1980 lines · 12 kittens · made for demo</span>
        </div>
      </footer>
    </div>
  )
}

function Terminal({title, lines, copyText, onCopy, id, copied}){
  return (
    <div className="card" style={{overflow:'hidden'}}>
      <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', padding:'12px 14px', borderBottom:'1px solid #eee', background:'#FAFAF9'}}>
        <span style={{fontWeight:800, fontSize:13}}>{title}</span>
        <button onClick={()=>onCopy(copyText,id)} style={{fontSize:12, padding:'6px 10px', borderRadius:999, border:'1px solid #ddd', background: copied===id ? '#DCFCE7':'white'}}>{copied===id ? '✓ copied':'⧉ copy'}</button>
      </div>
      <div style={{background:'#0B0B0B', color:'#E5E7EB', padding:14, minHeight:140}}>
        {lines.map((l,i)=>(
          <div key={i} className="mono" style={{fontSize:12, opacity: l.startsWith('$') ? 1 : .75, color: l.includes('✓') ? '#86EFAC' : l.startsWith('$') ? '#93C5FD' : '#E5E7EB'}}>{l}</div>
        ))}
      </div>
    </div>
  )
}

function ArchDiagram(){
  const [pulse, setPulse] = useState('flutter')
  return (
    <div style={{display:'grid', placeItems:'center', padding:'10px 0'}}>
      <svg width="860" height="140" viewBox="0 0 860 140" style={{maxWidth:'100%', height:'auto'}}>
        {/* flutter */}
        <g onClick={()=>setPulse('flutter')} style={{cursor:'pointer'}}>
          <rect x="10" y="20" width="240" height="100" rx="18" fill={pulse==='flutter'?'#FF6B6B':'white'} stroke="#FF6B6B" strokeWidth="2" />
          <text x="130" y="55" textAnchor="middle" fontSize="13" fontWeight="800" fill={pulse==='flutter'?'white':'#FF6B6B'}>Flutter App</text>
          <text x="130" y="74" textAnchor="middle" fontSize="10" fill={pulse==='flutter'?'white':'#636E72'}>http · shared_prefs</text>
          <text x="130" y="90" textAnchor="middle" fontSize="10" fill={pulse==='flutter'?'white':'#636E72'}>splash → onboarding → home</text>
          <circle cx="130" cy="108" r="6" fill={pulse==='flutter'?'white':'#FF6B6B'} style={{animation: pulse==='flutter'?'pulse .7s infinite':''}} />
        </g>
        {/* arrow */}
        <g>
          <line x1="250" y1="70" x2="310" y2="70" stroke="#111" strokeWidth="2" strokeDasharray="6 6" />
          <polygon points="310,70 300,64 300,76" fill="#111" />
          <text x="280" y="58" textAnchor="middle" fontSize="9" className="mono">REST</text>
        </g>
        {/* laravel */}
        <g onClick={()=>setPulse('laravel')} style={{cursor:'pointer'}}>
          <rect x="310" y="20" width="240" height="100" rx="18" fill={pulse==='laravel'?'#4ECDC4':'white'} stroke="#4ECDC4" strokeWidth="2" />
          <text x="430" y="55" textAnchor="middle" fontSize="13" fontWeight="800" fill={pulse==='laravel'?'white':'#0F766E'}>Laravel API</text>
          <text x="430" y="74" textAnchor="middle" fontSize="10" fill={pulse==='laravel'?'white':'#636E72'}>10 routes · Sanctum · Validation</text>
          <text x="430" y="90" textAnchor="middle" fontSize="10" fill={pulse==='laravel'?'white':'#636E72'}>:8000 /api/*</text>
          <circle cx="430" cy="108" r="6" fill={pulse==='laravel'?'white':'#4ECDC4'} style={{animation: pulse==='laravel'?'pulse .7s infinite':''}} />
        </g>
        <g>
          <line x1="550" y1="70" x2="610" y2="70" stroke="#111" strokeWidth="2" strokeDasharray="6 6" />
          <polygon points="610,70 600,64 600,76" fill="#111" />
          <text x="580" y="58" textAnchor="middle" fontSize="9" className="mono">Eloquent</text>
        </g>
        {/* db */}
        <g onClick={()=>setPulse('db')} style={{cursor:'pointer'}}>
          <rect x="610" y="20" width="240" height="100" rx="18" fill={pulse==='db'?'#FFD93D':'white'} stroke="#F59E0B" strokeWidth="2" />
          <text x="730" y="55" textAnchor="middle" fontSize="13" fontWeight="800" fill="#92400E">SQLite DB</text>
          <text x="730" y="74" textAnchor="middle" fontSize="10" fill="#636E72">users · kittens (12) · favorites</text>
          <text x="730" y="90" textAnchor="middle" fontSize="10" fill="#636E72">database.sqlite</text>
          <circle cx="730" cy="108" r="6" fill="#F59E0B" style={{animation: pulse==='db'?'pulse .7s infinite':''}} />
        </g>
      </svg>
      <div style={{fontSize:12, opacity:.6}}>اضغط أي مربع — يشعل النبضة ✨</div>
    </div>
  )
}

function PhonePreview({idx, large}){
  const screens=[
    {bg:'#FFF7ED', c:'🐱', t:'Splash', s:'3 ثواني → يفحص prefs'},
    {bg:'#E0F2FE', c:'👋', t:'Onboarding 1/3', s:'مشمش'},
    {bg:'#DCFCE7', c:'❤️', t:'Onboarding 2/3', s:'تصفح واحفظ'},
    {bg:'#FEF3C7', c:'🏠', t:'Onboarding 3/3', s:'ابدأ الآن →'},
    {bg:'white', c:'', t:'Login', s:'form + forgot →', grid:true},
    {bg:'white', c:'', t:'Home', s:'grid 2-col', grid:true},
    {bg:'white', c:'', t:'Fav/Prof', s:'♥ + logout', grid:true},
    {bg:'white', c:'🐱', t:'Detail', s:'تبني + مفضلة'},
  ]
  // map idx 0..6 to screens
  const map=[0,1,2,3,4,5,6,7]
  const sc=screens[map[idx%8]]
  return (
    <div style={{flex:1, background: sc.bg, display:'grid', placeItems:'center', padding:12, textAlign:'center'}}>
      {sc.grid && idx===4 ? (
        <div style={{width:'100%'}}>
          <div style={{display:'grid', gap:6}}>
            <div style={{height:36, borderRadius:10, border:'1px solid #ddd', background:'white', display:'grid', placeItems:'center', fontSize:11, color:'#999'}}>Email</div>
            <div style={{height:36, borderRadius:10, border:'1px solid #ddd', background:'white', display:'grid', placeItems:'center', fontSize:11, color:'#999'}}>Password •••</div>
            <div style={{height:36, borderRadius:999, background:'#FF6B6B', display:'grid', placeItems:'center', color:'white', fontWeight:800, fontSize:12}}>دخول</div>
          </div>
          <div style={{marginTop:8, fontSize:11, fontWeight:700}}>{sc.t}</div>
          <div style={{fontSize:10, opacity:.6}}>{sc.s}</div>
        </div>
      ) : sc.grid ? (
        <div style={{width:'100%'}}>
          <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:6}}>
            {[1,2,3,4].map(i=>(
              <div key={i} style={{background:'white', border:'1px solid #eee', borderRadius:12, overflow:'hidden'}}>
                <div style={{height: large? 70: 46, background: `hsl(${10+i*18} 85% 92%)`, display:'grid', placeItems:'center', fontSize:18}}>🐱</div>
                <div style={{padding:6, textAlign:'right'}}>
                  <div style={{fontSize:10, fontWeight:800}}>مشمش {i}</div>
                  <div style={{fontSize:9, opacity:.6}}>شيرازي · 120 ر.س</div>
                </div>
              </div>
            ))}
          </div>
          <div style={{marginTop:8, fontSize:11, fontWeight:700}}>{sc.t}</div>
        </div>
      ) : (
        <>
          <div style={{fontSize: large? 48:36}}>{sc.c}</div>
          <div style={{fontWeight:800, marginTop:6}}>{sc.t}</div>
          <div style={{fontSize:12, opacity:.6}}>{sc.s}</div>
        </>
      )}
    </div>
  )
}

function FlowSteps({idx, setIdx}){
  const steps=[
    {t:'Splash (3s)', d:'يفحص SharedPreferences: onboarding_done؟ token؟ يقرر المسار', c:'#FFF7ED'},
    {t:'Onboarding 1 — تعريف', d:'شعار + اسم التطبيق + نبذة', c:'#E0F2FE'},
    {t:'Onboarding 2 — خدمات', d:'تصفح، حفظ المفضلة، تبني', c:'#DCFCE7'},
    {t:'Onboarding 3 — ترحيب', d:'زر ابدأ الآن → يحفظ prefs', c:'#FEF3C7'},
    {t:'Auth — دخول/تسجيل/نسيت', d:'validation + إظهار الباسورد + روابط', c:'#FFE4E6'},
    {t:'Home — Grid', d:'GET /api/kittens → 12 بطاقة + Detail + تبني dialog', c:'#DCFCE7'},
    {t:'Profile — خروج', d:'يعرض user + logout يمسح token → Login', c:'#F3F4F6'},
  ]
  const s=steps[idx%7]
  return (
    <div>
      <div style={{display:'flex', gap:6, flexWrap:'wrap'}}>
        {steps.map((_,i)=>(
          <button key={i} onClick={()=>setIdx(i)} style={{padding:'6px 10px', borderRadius:999, border:'1px solid #e5e7eb', background: i===idx ? '#FF6B6B':'white', color: i===idx?'white':'#111', fontSize:12, fontWeight:700}}>{i+1}</button>
        ))}
      </div>
      <div className="card" style={{marginTop:12, padding:16, background: s.c, border:'1px solid rgba(0,0,0,.06)'}}>
        <div style={{fontWeight:800}}>{idx+1}. {s.t}</div>
        <div style={{fontSize:13, opacity:.7, marginTop:4, lineHeight:1.6}}>{s.d}</div>
        <div className="mono" style={{marginTop:8, fontSize:11, background:'white', padding:'8px 10px', borderRadius:10, border:'1px solid #eee'}}>
          {idx===0 && 'Future.delayed(3s) → prefs.getBool(onboarding_done)'}
          {idx===4 && 'ApiService.login(email,password) → token'}
          {idx===5 && 'FutureBuilder → GridView.count(2)'}
          {idx===6 && 'ApiService.logout() → clearToken()'}
          {[1,2,3].includes(idx) && 'PageView + indicator + prefs.setBool'}
        </div>
      </div>
    </div>
  )
}
