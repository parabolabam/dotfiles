"use strict";var vn=Object.create;var U=Object.defineProperty;var En=Object.getOwnPropertyDescriptor;var In=Object.getOwnPropertyNames;var Tn=Object.getPrototypeOf,Pn=Object.prototype.hasOwnProperty;var c=(e,t)=>()=>(t||e((t={exports:{}}).exports,t),t.exports),Cn=(e,t)=>{for(var r in t)U(e,r,{get:t[r],enumerable:!0})},Ge=(e,t,r,n)=>{if(t&&typeof t=="object"||typeof t=="function")for(let o of In(t))!Pn.call(e,o)&&o!==r&&U(e,o,{get:()=>t[o],enumerable:!(n=En(t,o))||n.enumerable});return e};var D=(e,t,r)=>(r=e!=null?vn(Tn(e)):{},Ge(t||!e||!e.__esModule?U(r,"default",{value:e,enumerable:!0}):r,e)),Gn=e=>Ge(U({},"__esModule",{value:!0}),e);var Ne=c((Ao,qe)=>{qe.exports=Re;Re.sync=On;var Ae=require("fs");function An(e,t){var r=t.pathExt!==void 0?t.pathExt:process.env.PATHEXT;if(!r||(r=r.split(";"),r.indexOf("")!==-1))return!0;for(var n=0;n<r.length;n++){var o=r[n].toLowerCase();if(o&&e.substr(-o.length).toLowerCase()===o)return!0}return!1}function Oe(e,t,r){return!e.isSymbolicLink()&&!e.isFile()?!1:An(t,r)}function Re(e,t,r){Ae.stat(e,function(n,o){r(n,n?!1:Oe(o,e,t))})}function On(e,t){return Oe(Ae.statSync(e),e,t)}});var Be=c((Oo,Le)=>{Le.exports=$e;$e.sync=Rn;var ke=require("fs");function $e(e,t,r){ke.stat(e,function(n,o){r(n,n?!1:_e(o,t))})}function Rn(e,t){return _e(ke.statSync(e),t)}function _e(e,t){return e.isFile()&&qn(e,t)}function qn(e,t){var r=e.mode,n=e.uid,o=e.gid,s=t.uid!==void 0?t.uid:process.getuid&&process.getuid(),i=t.gid!==void 0?t.gid:process.getgid&&process.getgid(),a=parseInt("100",8),u=parseInt("010",8),l=parseInt("001",8),f=a|u,h=r&l||r&u&&o===i||r&a&&n===s||r&f&&s===0;return h}});var je=c((qo,Me)=>{var Ro=require("fs"),H;process.platform==="win32"||global.TESTING_WINDOWS?H=Ne():H=Be();Me.exports=oe;oe.sync=Nn;function oe(e,t,r){if(typeof t=="function"&&(r=t,t={}),!r){if(typeof Promise!="function")throw new TypeError("callback not provided");return new Promise(function(n,o){oe(e,t||{},function(s,i){s?o(s):n(i)})})}H(e,t||{},function(n,o){n&&(n.code==="EACCES"||t&&t.ignoreErrors)&&(n=null,o=!1),r(n,o)})}function Nn(e,t){try{return H.sync(e,t||{})}catch(r){if(t&&t.ignoreErrors||r.code==="EACCES")return!1;throw r}}});var Ke=c((No,We)=>{var P=process.platform==="win32"||process.env.OSTYPE==="cygwin"||process.env.OSTYPE==="msys",Fe=require("path"),kn=P?";":":",Ue=je(),De=e=>Object.assign(new Error(`not found: ${e}`),{code:"ENOENT"}),He=(e,t)=>{let r=t.colon||kn,n=e.match(/\//)||P&&e.match(/\\/)?[""]:[...P?[process.cwd()]:[],...(t.path||process.env.PATH||"").split(r)],o=P?t.pathExt||process.env.PATHEXT||".EXE;.CMD;.BAT;.COM":"",s=P?o.split(r):[""];return P&&e.indexOf(".")!==-1&&s[0]!==""&&s.unshift(""),{pathEnv:n,pathExt:s,pathExtExe:o}},Xe=(e,t,r)=>{typeof t=="function"&&(r=t,t={}),t||(t={});let{pathEnv:n,pathExt:o,pathExtExe:s}=He(e,t),i=[],a=l=>new Promise((f,h)=>{if(l===n.length)return t.all&&i.length?f(i):h(De(e));let m=n[l],g=/^".*"$/.test(m)?m.slice(1,-1):m,y=Fe.join(g,e),S=!g&&/^\.[\\\/]/.test(e)?e.slice(0,2)+y:y;f(u(S,l,0))}),u=(l,f,h)=>new Promise((m,g)=>{if(h===o.length)return m(a(f+1));let y=o[h];Ue(l+y,{pathExt:s},(S,T)=>{if(!S&&T)if(t.all)i.push(l+y);else return m(l+y);return m(u(l,f,h+1))})});return r?a(0).then(l=>r(null,l),r):a(0)},$n=(e,t)=>{t=t||{};let{pathEnv:r,pathExt:n,pathExtExe:o}=He(e,t),s=[];for(let i=0;i<r.length;i++){let a=r[i],u=/^".*"$/.test(a)?a.slice(1,-1):a,l=Fe.join(u,e),f=!u&&/^\.[\\\/]/.test(e)?e.slice(0,2)+l:l;for(let h=0;h<n.length;h++){let m=f+n[h];try{if(Ue.sync(m,{pathExt:o}))if(t.all)s.push(m);else return m}catch{}}}if(t.all&&s.length)return s;if(t.nothrow)return null;throw De(e)};We.exports=Xe;Xe.sync=$n});var ie=c((ko,se)=>{"use strict";var ze=(e={})=>{let t=e.env||process.env;return(e.platform||process.platform)!=="win32"?"PATH":Object.keys(t).reverse().find(n=>n.toUpperCase()==="PATH")||"Path"};se.exports=ze;se.exports.default=ze});var Ze=c(($o,Qe)=>{"use strict";var Ve=require("path"),_n=Ke(),Ln=ie();function Ye(e,t){let r=e.options.env||process.env,n=process.cwd(),o=e.options.cwd!=null,s=o&&process.chdir!==void 0&&!process.chdir.disabled;if(s)try{process.chdir(e.options.cwd)}catch{}let i;try{i=_n.sync(e.command,{path:r[Ln({env:r})],pathExt:t?Ve.delimiter:void 0})}catch{}finally{s&&process.chdir(n)}return i&&(i=Ve.resolve(o?e.options.cwd:"",i)),i}function Bn(e){return Ye(e)||Ye(e,!0)}Qe.exports=Bn});var Je=c((_o,ce)=>{"use strict";var ae=/([()\][%!^"`<>&|;, *?])/g;function Mn(e){return e=e.replace(ae,"^$1"),e}function jn(e,t){return e=`${e}`,e=e.replace(/(\\*)"/g,'$1$1\\"'),e=e.replace(/(\\*)$/,"$1$1"),e=`"${e}"`,e=e.replace(ae,"^$1"),t&&(e=e.replace(ae,"^$1")),e}ce.exports.command=Mn;ce.exports.argument=jn});var tt=c((Lo,et)=>{"use strict";et.exports=/^#!(.*)/});var rt=c((Bo,nt)=>{"use strict";var Fn=tt();nt.exports=(e="")=>{let t=e.match(Fn);if(!t)return null;let[r,n]=t[0].replace(/#! ?/,"").split(" "),o=r.split("/").pop();return o==="env"?n:n?`${o} ${n}`:o}});var st=c((Mo,ot)=>{"use strict";var ue=require("fs"),Un=rt();function Dn(e){let r=Buffer.alloc(150),n;try{n=ue.openSync(e,"r"),ue.readSync(n,r,0,150,0),ue.closeSync(n)}catch{}return Un(r.toString())}ot.exports=Dn});var ut=c((jo,ct)=>{"use strict";var Hn=require("path"),it=Ze(),at=Je(),Xn=st(),Wn=process.platform==="win32",Kn=/\.(?:com|exe)$/i,zn=/node_modules[\\/].bin[\\/][^\\/]+\.cmd$/i;function Vn(e){e.file=it(e);let t=e.file&&Xn(e.file);return t?(e.args.unshift(e.file),e.command=t,it(e)):e.file}function Yn(e){if(!Wn)return e;let t=Vn(e),r=!Kn.test(t);if(e.options.forceShell||r){let n=zn.test(t);e.command=Hn.normalize(e.command),e.command=at.command(e.command),e.args=e.args.map(s=>at.argument(s,n));let o=[e.command].concat(e.args).join(" ");e.args=["/d","/s","/c",`"${o}"`],e.command=process.env.comspec||"cmd.exe",e.options.windowsVerbatimArguments=!0}return e}function Qn(e,t,r){t&&!Array.isArray(t)&&(r=t,t=null),t=t?t.slice(0):[],r=Object.assign({},r);let n={command:e,args:t,options:r,file:void 0,original:{command:e,args:t}};return r.shell?n:Yn(n)}ct.exports=Qn});var ft=c((Fo,dt)=>{"use strict";var le=process.platform==="win32";function de(e,t){return Object.assign(new Error(`${t} ${e.command} ENOENT`),{code:"ENOENT",errno:"ENOENT",syscall:`${t} ${e.command}`,path:e.command,spawnargs:e.args})}function Zn(e,t){if(!le)return;let r=e.emit;e.emit=function(n,o){if(n==="exit"){let s=lt(o,t,"spawn");if(s)return r.call(e,"error",s)}return r.apply(e,arguments)}}function lt(e,t){return le&&e===1&&!t.file?de(t.original,"spawn"):null}function Jn(e,t){return le&&e===1&&!t.file?de(t.original,"spawnSync"):null}dt.exports={hookChildProcess:Zn,verifyENOENT:lt,verifyENOENTSync:Jn,notFoundError:de}});var ht=c((Uo,C)=>{"use strict";var pt=require("child_process"),fe=ut(),pe=ft();function mt(e,t,r){let n=fe(e,t,r),o=pt.spawn(n.command,n.args,n.options);return pe.hookChildProcess(o,n),o}function er(e,t,r){let n=fe(e,t,r),o=pt.spawnSync(n.command,n.args,n.options);return o.error=o.error||pe.verifyENOENTSync(o.status,n),o}C.exports=mt;C.exports.spawn=mt;C.exports.sync=er;C.exports._parse=fe;C.exports._enoent=pe});var yt=c((Do,gt)=>{"use strict";gt.exports=e=>{let t=typeof e=="string"?`
`:`
`.charCodeAt(),r=typeof e=="string"?"\r":"\r".charCodeAt();return e[e.length-1]===t&&(e=e.slice(0,e.length-1)),e[e.length-1]===r&&(e=e.slice(0,e.length-1)),e}});var wt=c((Ho,_)=>{"use strict";var $=require("path"),St=ie(),xt=e=>{e={cwd:process.cwd(),path:process.env[St()],execPath:process.execPath,...e};let t,r=$.resolve(e.cwd),n=[];for(;t!==r;)n.push($.join(r,"node_modules/.bin")),t=r,r=$.resolve(r,"..");let o=$.resolve(e.cwd,e.execPath,"..");return n.push(o),n.concat(e.path).join($.delimiter)};_.exports=xt;_.exports.default=xt;_.exports.env=e=>{e={env:process.env,...e};let t={...e.env},r=St({env:t});return e.path=t[r],t[r]=_.exports(e),t}});var vt=c((Xo,me)=>{"use strict";var bt=(e,t)=>{for(let r of Reflect.ownKeys(t))Object.defineProperty(e,r,Object.getOwnPropertyDescriptor(t,r));return e};me.exports=bt;me.exports.default=bt});var It=c((Wo,W)=>{"use strict";var tr=vt(),X=new WeakMap,Et=(e,t={})=>{if(typeof e!="function")throw new TypeError("Expected a function");let r,n=0,o=e.displayName||e.name||"<anonymous>",s=function(...i){if(X.set(s,++n),n===1)r=e.apply(this,i),e=null;else if(t.throw===!0)throw new Error(`Function \`${o}\` can only be called once`);return r};return tr(s,e),X.set(s,n),s};W.exports=Et;W.exports.default=Et;W.exports.callCount=e=>{if(!X.has(e))throw new Error(`The given function \`${e.name}\` is not wrapped by the \`onetime\` package`);return X.get(e)}});var Tt=c(K=>{"use strict";Object.defineProperty(K,"__esModule",{value:!0});K.SIGNALS=void 0;var nr=[{name:"SIGHUP",number:1,action:"terminate",description:"Terminal closed",standard:"posix"},{name:"SIGINT",number:2,action:"terminate",description:"User interruption with CTRL-C",standard:"ansi"},{name:"SIGQUIT",number:3,action:"core",description:"User interruption with CTRL-\\",standard:"posix"},{name:"SIGILL",number:4,action:"core",description:"Invalid machine instruction",standard:"ansi"},{name:"SIGTRAP",number:5,action:"core",description:"Debugger breakpoint",standard:"posix"},{name:"SIGABRT",number:6,action:"core",description:"Aborted",standard:"ansi"},{name:"SIGIOT",number:6,action:"core",description:"Aborted",standard:"bsd"},{name:"SIGBUS",number:7,action:"core",description:"Bus error due to misaligned, non-existing address or paging error",standard:"bsd"},{name:"SIGEMT",number:7,action:"terminate",description:"Command should be emulated but is not implemented",standard:"other"},{name:"SIGFPE",number:8,action:"core",description:"Floating point arithmetic error",standard:"ansi"},{name:"SIGKILL",number:9,action:"terminate",description:"Forced termination",standard:"posix",forced:!0},{name:"SIGUSR1",number:10,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGSEGV",number:11,action:"core",description:"Segmentation fault",standard:"ansi"},{name:"SIGUSR2",number:12,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGPIPE",number:13,action:"terminate",description:"Broken pipe or socket",standard:"posix"},{name:"SIGALRM",number:14,action:"terminate",description:"Timeout or timer",standard:"posix"},{name:"SIGTERM",number:15,action:"terminate",description:"Termination",standard:"ansi"},{name:"SIGSTKFLT",number:16,action:"terminate",description:"Stack is empty or overflowed",standard:"other"},{name:"SIGCHLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"posix"},{name:"SIGCLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"other"},{name:"SIGCONT",number:18,action:"unpause",description:"Unpaused",standard:"posix",forced:!0},{name:"SIGSTOP",number:19,action:"pause",description:"Paused",standard:"posix",forced:!0},{name:"SIGTSTP",number:20,action:"pause",description:'Paused using CTRL-Z or "suspend"',standard:"posix"},{name:"SIGTTIN",number:21,action:"pause",description:"Background process cannot read terminal input",standard:"posix"},{name:"SIGBREAK",number:21,action:"terminate",description:"User interruption with CTRL-BREAK",standard:"other"},{name:"SIGTTOU",number:22,action:"pause",description:"Background process cannot write to terminal output",standard:"posix"},{name:"SIGURG",number:23,action:"ignore",description:"Socket received out-of-band data",standard:"bsd"},{name:"SIGXCPU",number:24,action:"core",description:"Process timed out",standard:"bsd"},{name:"SIGXFSZ",number:25,action:"core",description:"File too big",standard:"bsd"},{name:"SIGVTALRM",number:26,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGPROF",number:27,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGWINCH",number:28,action:"ignore",description:"Terminal window size changed",standard:"bsd"},{name:"SIGIO",number:29,action:"terminate",description:"I/O is available",standard:"other"},{name:"SIGPOLL",number:29,action:"terminate",description:"Watched event",standard:"other"},{name:"SIGINFO",number:29,action:"ignore",description:"Request for process information",standard:"other"},{name:"SIGPWR",number:30,action:"terminate",description:"Device running out of power",standard:"systemv"},{name:"SIGSYS",number:31,action:"core",description:"Invalid system call",standard:"other"},{name:"SIGUNUSED",number:31,action:"terminate",description:"Invalid system call",standard:"other"}];K.SIGNALS=nr});var he=c(G=>{"use strict";Object.defineProperty(G,"__esModule",{value:!0});G.SIGRTMAX=G.getRealtimeSignals=void 0;var rr=function(){let e=Ct-Pt+1;return Array.from({length:e},or)};G.getRealtimeSignals=rr;var or=function(e,t){return{name:`SIGRT${t+1}`,number:Pt+t,action:"terminate",description:"Application-specific signal (realtime)",standard:"posix"}},Pt=34,Ct=64;G.SIGRTMAX=Ct});var Gt=c(z=>{"use strict";Object.defineProperty(z,"__esModule",{value:!0});z.getSignals=void 0;var sr=require("os"),ir=Tt(),ar=he(),cr=function(){let e=(0,ar.getRealtimeSignals)();return[...ir.SIGNALS,...e].map(ur)};z.getSignals=cr;var ur=function({name:e,number:t,description:r,action:n,forced:o=!1,standard:s}){let{signals:{[e]:i}}=sr.constants,a=i!==void 0;return{name:e,number:a?i:t,description:r,supported:a,action:n,forced:o,standard:s}}});var Ot=c(A=>{"use strict";Object.defineProperty(A,"__esModule",{value:!0});A.signalsByNumber=A.signalsByName=void 0;var lr=require("os"),At=Gt(),dr=he(),fr=function(){return(0,At.getSignals)().reduce(pr,{})},pr=function(e,{name:t,number:r,description:n,supported:o,action:s,forced:i,standard:a}){return{...e,[t]:{name:t,number:r,description:n,supported:o,action:s,forced:i,standard:a}}},mr=fr();A.signalsByName=mr;var hr=function(){let e=(0,At.getSignals)(),t=dr.SIGRTMAX+1,r=Array.from({length:t},(n,o)=>gr(o,e));return Object.assign({},...r)},gr=function(e,t){let r=yr(e,t);if(r===void 0)return{};let{name:n,description:o,supported:s,action:i,forced:a,standard:u}=r;return{[e]:{name:n,number:e,description:o,supported:s,action:i,forced:a,standard:u}}},yr=function(e,t){let r=t.find(({name:n})=>lr.constants.signals[n]===e);return r!==void 0?r:t.find(n=>n.number===e)},Sr=hr();A.signalsByNumber=Sr});var qt=c((Qo,Rt)=>{"use strict";var{signalsByName:xr}=Ot(),wr=({timedOut:e,timeout:t,errorCode:r,signal:n,signalDescription:o,exitCode:s,isCanceled:i})=>e?`timed out after ${t} milliseconds`:i?"was canceled":r!==void 0?`failed with ${r}`:n!==void 0?`was killed with ${n} (${o})`:s!==void 0?`failed with exit code ${s}`:"failed",br=({stdout:e,stderr:t,all:r,error:n,signal:o,exitCode:s,command:i,escapedCommand:a,timedOut:u,isCanceled:l,killed:f,parsed:{options:{timeout:h}}})=>{s=s===null?void 0:s,o=o===null?void 0:o;let m=o===void 0?void 0:xr[o].description,g=n&&n.code,S=`Command ${wr({timedOut:u,timeout:h,errorCode:g,signal:o,signalDescription:m,exitCode:s,isCanceled:l})}: ${i}`,T=Object.prototype.toString.call(n)==="[object Error]",j=T?`${S}
${n.message}`:S,F=[j,t,e].filter(Boolean).join(`
`);return T?(n.originalMessage=n.message,n.message=F):n=new Error(F),n.shortMessage=j,n.command=i,n.escapedCommand=a,n.exitCode=s,n.signal=o,n.signalDescription=m,n.stdout=e,n.stderr=t,r!==void 0&&(n.all=r),"bufferedData"in n&&delete n.bufferedData,n.failed=!0,n.timedOut=!!u,n.isCanceled=l,n.killed=f&&!u,n};Rt.exports=br});var kt=c((Zo,ge)=>{"use strict";var V=["stdin","stdout","stderr"],vr=e=>V.some(t=>e[t]!==void 0),Nt=e=>{if(!e)return;let{stdio:t}=e;if(t===void 0)return V.map(n=>e[n]);if(vr(e))throw new Error(`It's not possible to provide \`stdio\` in combination with one of ${V.map(n=>`\`${n}\``).join(", ")}`);if(typeof t=="string")return t;if(!Array.isArray(t))throw new TypeError(`Expected \`stdio\` to be of type \`string\` or \`Array\`, got \`${typeof t}\``);let r=Math.max(t.length,V.length);return Array.from({length:r},(n,o)=>t[o])};ge.exports=Nt;ge.exports.node=e=>{let t=Nt(e);return t==="ipc"?"ipc":t===void 0||typeof t=="string"?[t,t,t,"ipc"]:t.includes("ipc")?t:[...t,"ipc"]}});var $t=c((Jo,Y)=>{Y.exports=["SIGABRT","SIGALRM","SIGHUP","SIGINT","SIGTERM"];process.platform!=="win32"&&Y.exports.push("SIGVTALRM","SIGXCPU","SIGXFSZ","SIGUSR2","SIGTRAP","SIGSYS","SIGQUIT","SIGIOT");process.platform==="linux"&&Y.exports.push("SIGIO","SIGPOLL","SIGPWR","SIGSTKFLT","SIGUNUSED")});var jt=c((es,q)=>{var d=global.process,v=function(e){return e&&typeof e=="object"&&typeof e.removeListener=="function"&&typeof e.emit=="function"&&typeof e.reallyExit=="function"&&typeof e.listeners=="function"&&typeof e.kill=="function"&&typeof e.pid=="number"&&typeof e.on=="function"};v(d)?(_t=require("assert"),O=$t(),Lt=/^win/i.test(d.platform),L=require("events"),typeof L!="function"&&(L=L.EventEmitter),d.__signal_exit_emitter__?p=d.__signal_exit_emitter__:(p=d.__signal_exit_emitter__=new L,p.count=0,p.emitted={}),p.infinite||(p.setMaxListeners(1/0),p.infinite=!0),q.exports=function(e,t){if(!v(global.process))return function(){};_t.equal(typeof e,"function","a callback must be provided for exit handler"),R===!1&&ye();var r="exit";t&&t.alwaysLast&&(r="afterexit");var n=function(){p.removeListener(r,e),p.listeners("exit").length===0&&p.listeners("afterexit").length===0&&Q()};return p.on(r,e),n},Q=function(){!R||!v(global.process)||(R=!1,O.forEach(function(t){try{d.removeListener(t,Z[t])}catch{}}),d.emit=J,d.reallyExit=Se,p.count-=1)},q.exports.unload=Q,E=function(t,r,n){p.emitted[t]||(p.emitted[t]=!0,p.emit(t,r,n))},Z={},O.forEach(function(e){Z[e]=function(){if(v(global.process)){var r=d.listeners(e);r.length===p.count&&(Q(),E("exit",null,e),E("afterexit",null,e),Lt&&e==="SIGHUP"&&(e="SIGINT"),d.kill(d.pid,e))}}}),q.exports.signals=function(){return O},R=!1,ye=function(){R||!v(global.process)||(R=!0,p.count+=1,O=O.filter(function(t){try{return d.on(t,Z[t]),!0}catch{return!1}}),d.emit=Mt,d.reallyExit=Bt)},q.exports.load=ye,Se=d.reallyExit,Bt=function(t){v(global.process)&&(d.exitCode=t||0,E("exit",d.exitCode,null),E("afterexit",d.exitCode,null),Se.call(d,d.exitCode))},J=d.emit,Mt=function(t,r){if(t==="exit"&&v(global.process)){r!==void 0&&(d.exitCode=r);var n=J.apply(this,arguments);return E("exit",d.exitCode,null),E("afterexit",d.exitCode,null),n}else return J.apply(this,arguments)}):q.exports=function(){return function(){}};var _t,O,Lt,L,p,Q,E,Z,R,ye,Se,Bt,J,Mt});var Ut=c((ts,Ft)=>{"use strict";var Er=require("os"),Ir=jt(),Tr=1e3*5,Pr=(e,t="SIGTERM",r={})=>{let n=e(t);return Cr(e,t,r,n),n},Cr=(e,t,r,n)=>{if(!Gr(t,r,n))return;let o=Or(r),s=setTimeout(()=>{e("SIGKILL")},o);s.unref&&s.unref()},Gr=(e,{forceKillAfterTimeout:t},r)=>Ar(e)&&t!==!1&&r,Ar=e=>e===Er.constants.signals.SIGTERM||typeof e=="string"&&e.toUpperCase()==="SIGTERM",Or=({forceKillAfterTimeout:e=!0})=>{if(e===!0)return Tr;if(!Number.isFinite(e)||e<0)throw new TypeError(`Expected the \`forceKillAfterTimeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`);return e},Rr=(e,t)=>{e.kill()&&(t.isCanceled=!0)},qr=(e,t,r)=>{e.kill(t),r(Object.assign(new Error("Timed out"),{timedOut:!0,signal:t}))},Nr=(e,{timeout:t,killSignal:r="SIGTERM"},n)=>{if(t===0||t===void 0)return n;let o,s=new Promise((a,u)=>{o=setTimeout(()=>{qr(e,r,u)},t)}),i=n.finally(()=>{clearTimeout(o)});return Promise.race([s,i])},kr=({timeout:e})=>{if(e!==void 0&&(!Number.isFinite(e)||e<0))throw new TypeError(`Expected the \`timeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`)},$r=async(e,{cleanup:t,detached:r},n)=>{if(!t||r)return n;let o=Ir(()=>{e.kill()});return n.finally(()=>{o()})};Ft.exports={spawnedKill:Pr,spawnedCancel:Rr,setupTimeout:Nr,validateTimeout:kr,setExitHandler:$r}});var Ht=c((ns,Dt)=>{"use strict";var x=e=>e!==null&&typeof e=="object"&&typeof e.pipe=="function";x.writable=e=>x(e)&&e.writable!==!1&&typeof e._write=="function"&&typeof e._writableState=="object";x.readable=e=>x(e)&&e.readable!==!1&&typeof e._read=="function"&&typeof e._readableState=="object";x.duplex=e=>x.writable(e)&&x.readable(e);x.transform=e=>x.duplex(e)&&typeof e._transform=="function";Dt.exports=x});var Wt=c((rs,Xt)=>{"use strict";var{PassThrough:_r}=require("stream");Xt.exports=e=>{e={...e};let{array:t}=e,{encoding:r}=e,n=r==="buffer",o=!1;t?o=!(r||n):r=r||"utf8",n&&(r=null);let s=new _r({objectMode:o});r&&s.setEncoding(r);let i=0,a=[];return s.on("data",u=>{a.push(u),o?i=a.length:i+=u.length}),s.getBufferedValue=()=>t?a:n?Buffer.concat(a,i):a.join(""),s.getBufferedLength=()=>i,s}});var Kt=c((os,B)=>{"use strict";var{constants:Lr}=require("buffer"),Br=require("stream"),{promisify:Mr}=require("util"),jr=Wt(),Fr=Mr(Br.pipeline),ee=class extends Error{constructor(){super("maxBuffer exceeded"),this.name="MaxBufferError"}};async function xe(e,t){if(!e)throw new Error("Expected a stream");t={maxBuffer:1/0,...t};let{maxBuffer:r}=t,n=jr(t);return await new Promise((o,s)=>{let i=a=>{a&&n.getBufferedLength()<=Lr.MAX_LENGTH&&(a.bufferedData=n.getBufferedValue()),s(a)};(async()=>{try{await Fr(e,n),o()}catch(a){i(a)}})(),n.on("data",()=>{n.getBufferedLength()>r&&i(new ee)})}),n.getBufferedValue()}B.exports=xe;B.exports.buffer=(e,t)=>xe(e,{...t,encoding:"buffer"});B.exports.array=(e,t)=>xe(e,{...t,array:!0});B.exports.MaxBufferError=ee});var Vt=c((ss,zt)=>{"use strict";var{PassThrough:Ur}=require("stream");zt.exports=function(){var e=[],t=new Ur({objectMode:!0});return t.setMaxListeners(0),t.add=r,t.isEmpty=n,t.on("unpipe",o),Array.prototype.slice.call(arguments).forEach(r),t;function r(s){return Array.isArray(s)?(s.forEach(r),this):(e.push(s),s.once("end",o.bind(null,s)),s.once("error",t.emit.bind(t,"error")),s.pipe(t,{end:!1}),this)}function n(){return e.length==0}function o(s){e=e.filter(function(i){return i!==s}),!e.length&&t.readable&&t.end()}}});var Jt=c((is,Zt)=>{"use strict";var Qt=Ht(),Yt=Kt(),Dr=Vt(),Hr=(e,t)=>{t===void 0||e.stdin===void 0||(Qt(t)?t.pipe(e.stdin):e.stdin.end(t))},Xr=(e,{all:t})=>{if(!t||!e.stdout&&!e.stderr)return;let r=Dr();return e.stdout&&r.add(e.stdout),e.stderr&&r.add(e.stderr),r},we=async(e,t)=>{if(e){e.destroy();try{return await t}catch(r){return r.bufferedData}}},be=(e,{encoding:t,buffer:r,maxBuffer:n})=>{if(!(!e||!r))return t?Yt(e,{encoding:t,maxBuffer:n}):Yt.buffer(e,{maxBuffer:n})},Wr=async({stdout:e,stderr:t,all:r},{encoding:n,buffer:o,maxBuffer:s},i)=>{let a=be(e,{encoding:n,buffer:o,maxBuffer:s}),u=be(t,{encoding:n,buffer:o,maxBuffer:s}),l=be(r,{encoding:n,buffer:o,maxBuffer:s*2});try{return await Promise.all([i,a,u,l])}catch(f){return Promise.all([{error:f,signal:f.signal,timedOut:f.timedOut},we(e,a),we(t,u),we(r,l)])}},Kr=({input:e})=>{if(Qt(e))throw new TypeError("The `input` option cannot be a stream in sync mode")};Zt.exports={handleInput:Hr,makeAllStream:Xr,getSpawnedResult:Wr,validateInputSync:Kr}});var tn=c((as,en)=>{"use strict";var zr=(async()=>{})().constructor.prototype,Vr=["then","catch","finally"].map(e=>[e,Reflect.getOwnPropertyDescriptor(zr,e)]),Yr=(e,t)=>{for(let[r,n]of Vr){let o=typeof t=="function"?(...s)=>Reflect.apply(n.value,t(),s):n.value.bind(t);Reflect.defineProperty(e,r,{...n,value:o})}return e},Qr=e=>new Promise((t,r)=>{e.on("exit",(n,o)=>{t({exitCode:n,signal:o})}),e.on("error",n=>{r(n)}),e.stdin&&e.stdin.on("error",n=>{r(n)})});en.exports={mergePromise:Yr,getSpawnedPromise:Qr}});var on=c((cs,rn)=>{"use strict";var nn=(e,t=[])=>Array.isArray(t)?[e,...t]:[e],Zr=/^[\w.-]+$/,Jr=/"/g,eo=e=>typeof e!="string"||Zr.test(e)?e:`"${e.replace(Jr,'\\"')}"`,to=(e,t)=>nn(e,t).join(" "),no=(e,t)=>nn(e,t).map(r=>eo(r)).join(" "),ro=/ +/g,oo=e=>{let t=[];for(let r of e.trim().split(ro)){let n=t[t.length-1];n&&n.endsWith("\\")?t[t.length-1]=`${n.slice(0,-1)} ${r}`:t.push(r)}return t};rn.exports={joinCommand:to,getEscapedCommand:no,parseCommand:oo}});var fn=c((us,N)=>{"use strict";var so=require("path"),ve=require("child_process"),io=ht(),ao=yt(),co=wt(),uo=It(),te=qt(),an=kt(),{spawnedKill:lo,spawnedCancel:fo,setupTimeout:po,validateTimeout:mo,setExitHandler:ho}=Ut(),{handleInput:go,getSpawnedResult:yo,makeAllStream:So,validateInputSync:xo}=Jt(),{mergePromise:sn,getSpawnedPromise:wo}=tn(),{joinCommand:cn,parseCommand:un,getEscapedCommand:ln}=on(),bo=1e3*1e3*100,vo=({env:e,extendEnv:t,preferLocal:r,localDir:n,execPath:o})=>{let s=t?{...process.env,...e}:e;return r?co.env({env:s,cwd:n,execPath:o}):s},dn=(e,t,r={})=>{let n=io._parse(e,t,r);return e=n.command,t=n.args,r=n.options,r={maxBuffer:bo,buffer:!0,stripFinalNewline:!0,extendEnv:!0,preferLocal:!1,localDir:r.cwd||process.cwd(),execPath:process.execPath,encoding:"utf8",reject:!0,cleanup:!0,all:!1,windowsHide:!0,...r},r.env=vo(r),r.stdio=an(r),process.platform==="win32"&&so.basename(e,".exe")==="cmd"&&t.unshift("/q"),{file:e,args:t,options:r,parsed:n}},M=(e,t,r)=>typeof t!="string"&&!Buffer.isBuffer(t)?r===void 0?void 0:"":e.stripFinalNewline?ao(t):t,ne=(e,t,r)=>{let n=dn(e,t,r),o=cn(e,t),s=ln(e,t);mo(n.options);let i;try{i=ve.spawn(n.file,n.args,n.options)}catch(g){let y=new ve.ChildProcess,S=Promise.reject(te({error:g,stdout:"",stderr:"",all:"",command:o,escapedCommand:s,parsed:n,timedOut:!1,isCanceled:!1,killed:!1}));return sn(y,S)}let a=wo(i),u=po(i,n.options,a),l=ho(i,n.options,u),f={isCanceled:!1};i.kill=lo.bind(null,i.kill.bind(i)),i.cancel=fo.bind(null,i,f);let m=uo(async()=>{let[{error:g,exitCode:y,signal:S,timedOut:T},j,F,bn]=await yo(i,n.options,l),Ie=M(n.options,j),Te=M(n.options,F),Pe=M(n.options,bn);if(g||y!==0||S!==null){let Ce=te({error:g,exitCode:y,signal:S,stdout:Ie,stderr:Te,all:Pe,command:o,escapedCommand:s,parsed:n,timedOut:T,isCanceled:f.isCanceled,killed:i.killed});if(!n.options.reject)return Ce;throw Ce}return{command:o,escapedCommand:s,exitCode:0,stdout:Ie,stderr:Te,all:Pe,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}});return go(i,n.options.input),i.all=So(i,n.options),sn(i,m)};N.exports=ne;N.exports.sync=(e,t,r)=>{let n=dn(e,t,r),o=cn(e,t),s=ln(e,t);xo(n.options);let i;try{i=ve.spawnSync(n.file,n.args,n.options)}catch(l){throw te({error:l,stdout:"",stderr:"",all:"",command:o,escapedCommand:s,parsed:n,timedOut:!1,isCanceled:!1,killed:!1})}let a=M(n.options,i.stdout,i.error),u=M(n.options,i.stderr,i.error);if(i.error||i.status!==0||i.signal!==null){let l=te({stdout:a,stderr:u,error:i.error,signal:i.signal,exitCode:i.status,command:o,escapedCommand:s,parsed:n,timedOut:i.error&&i.error.code==="ETIMEDOUT",isCanceled:!1,killed:i.signal!==null});if(!n.options.reject)return l;throw l}return{command:o,escapedCommand:s,exitCode:0,stdout:a,stderr:u,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}};N.exports.command=(e,t)=>{let[r,...n]=un(e);return ne(r,n,t)};N.exports.commandSync=(e,t)=>{let[r,...n]=un(e);return ne.sync(r,n,t)};N.exports.node=(e,t,r={})=>{t&&!Array.isArray(t)&&typeof t=="object"&&(r=t,t=[]);let n=an.node(r),o=process.execArgv.filter(a=>!a.startsWith("--inspect")),{nodePath:s=process.execPath,nodeOptions:i=o}=r;return ne(s,[...i,e,...Array.isArray(t)?t:[]],{...r,stdin:void 0,stdout:void 0,stderr:void 0,stdio:n,shell:!1})}});var Co={};Cn(Co,{default:()=>wn});module.exports=Gn(Co);var pn=D(require("node:process"),1),mn=D(fn(),1);async function hn(e,{humanReadableOutput:t=!0}={}){if(pn.default.platform!=="darwin")throw new Error("macOS only");let r=t?[]:["-ss"],{stdout:n}=await(0,mn.default)("osascript",["-e",e,r]);return n}var b=require("@raycast/api"),re=require("react");var w=require("@raycast/api"),yn=D(require("path"));var gn=D(require("path"),1);function Ee(e,t={}){if(typeof e!="string")throw new TypeError(`Expected a string, got ${typeof e}`);let{resolve:r=!0}=t,n=e;return r&&(n=gn.default.resolve(e)),n=n.replace(/\\/g,"/"),n[0]!=="/"&&(n=`/${n}`),encodeURI(`file://${n}`).replace(/[?#]/g,encodeURIComponent)}var k=require("react/jsx-runtime"),Eo=()=>(0,k.jsx)(w.Action.Open,{title:"Open System Preferences",icon:w.Icon.Gear,target:"x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"}),Io=()=>(0,k.jsx)(w.ActionPanel,{children:(0,k.jsx)(Eo,{})}),To=`## Raycast needs automation access to iTerm.

1. Open **System Settings**
1. Open the **Privacy & Security** Preferences pane 
1. Then select the **Automation** tab
1. Expand **Raycast** from the list of applications
1. Ensure the **iTerm**  toggle is enabled as shown in the image below
1. When prompted enter your password

![Full Disk Access Preferences Pane](${Ee(yn.default.join(w.environment.assetsPath,"permission-raycast-automation.png"))})
`,Sn=e=>e.indexOf("Command failed with exit code 1: osascript -e")!==-1,xn=()=>(0,k.jsx)(w.Detail,{markdown:To,navigationTitle:"Permission Issue with Raycast",actions:(0,k.jsx)(Io,{})});var I=require("react/jsx-runtime"),Po=`
  tell application "iTerm"
    activate
    repeat until application "iTerm" is running
      delay 0.1
    end repeat
    
    create window with default profile
    activate
  end tell
`;function wn(){let[e,t]=(0,re.useState)(!1),r=()=>{hn(Po).then(async()=>{await(0,b.closeMainWindow)(),await(0,b.popToRoot)()}).catch(async n=>{if(Sn(n.message)){t(!0);return}await(0,b.showToast)({style:b.Toast.Style.Failure,title:"Cannot create new iTerm window",message:n.message})})};return(0,re.useEffect)(()=>{r()},[]),(0,I.jsxs)(I.Fragment,{children:[e&&(0,I.jsx)(xn,{}),!e&&(0,I.jsx)(b.Detail,{isLoading:!0,navigationTitle:"Creating iTerm Window...",markdown:"Creating iTerm Window..."})]})}
