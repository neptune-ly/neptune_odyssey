// Neptune Odyssey — Brandprint codec (reference implementation) · v1 · Neptune.Fintech
// Deterministic, portable theme string. 28-byte fixed layout -> base64url, version "NO1-", checksummed.
// Registries are APPEND-ONLY — never reorder (indices are the wire format). See docs/11-config-hash.md.
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.NeptuneBrandprint = factory();
}(typeof self !== 'undefined' ? self : this, function () {
  const FONTS  = ["Hanken Grotesk","Bricolage Grotesque","Space Grotesk","Sora","IBM Plex Sans Arabic","Reem Kufi","Tajawal","Readex Pro","Noto Kufi Arabic"];
  const LOGIN  = ["depth-emblem","arcade-arches","light-grid-spark","shield-guilloche"];
  const HERO   = ["balance-cards","warm-balance-cards","wallet-hero","restrained-balance"];
  const TONE   = ["clear-calm","warm-hospitable","light-instant","formal-authoritative"];
  const GLASS  = ["oceanic","warm-amber","violet-luminous","navy-steel"];
  const MOTION = ["smooth-fluid","calm-graceful","light-quick-crisp","stable-minimal-authoritative"];
  const ix = (a,v)=>{ const i=a.indexOf(v); return i<0?0:i; };
  const b64url = b => (typeof btoa!=='undefined' ? btoa(String.fromCharCode.apply(null,b)) : Buffer.from(b).toString('base64')).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
  const unb64url = s => { s=s.replace(/-/g,'+').replace(/_/g,'/'); while(s.length%4)s+='='; const bin = (typeof atob!=='undefined'?atob(s):Buffer.from(s,'base64').toString('binary')); return Uint8Array.from(bin,c=>c.charCodeAt(0)); };
  function encode(cfg){
  const buf=new Uint8Array(28), dv=new DataView(buf.buffer); let o=0;
  buf[o++]=1;                                            // version
  buf[o++]=Math.round(cfg.primary.L*255);
  buf[o++]=Math.min(255,Math.round(cfg.primary.C*1000));
  dv.setUint16(o,cfg.primary.H); o+=2;
  buf[o++]=Math.round(cfg.tertiary.L*255);
  buf[o++]=Math.min(255,Math.round(cfg.tertiary.C*1000));
  dv.setUint16(o,cfg.tertiary.H); o+=2;
  for(const k of ['xs','sm','md','lg','xl','xxl']) buf[o++]=Math.min(255,cfg.corners[k]);
  buf[o++]=Math.round(cfg.displayWeight/100);
  dv.setInt8(o,Math.round(cfg.displayTracking*1000)); o+=1;
  buf[o++]=ix(FONTS,cfg.fonts.display);
  buf[o++]=ix(FONTS,cfg.fonts.text);
  buf[o++]=ix(FONTS,cfg.fonts.num);
  buf[o++]=ix(LOGIN,cfg.loginShell);
  buf[o++]=ix(HERO,cfg.dashboardHero);
  buf[o++]=ix(TONE,cfg.contentTone);
  buf[o++]=ix(GLASS,cfg.glassTint);
  buf[o++]=ix(MOTION,cfg.motion);
  let f=0; if(cfg.defaultDark)f|=1; if(cfg.defaultRtl)f|=2; buf[o++]=f;
  buf[o++]=0;                                            // reserved
  let sum=0; for(let i=0;i<o;i++) sum=(sum+buf[i])&255; buf[o++]=sum;  // checksum
  return 'NO1-'+b64url(buf.subarray(0,28));
}
  function decode(str){
  if(!/^NO1-/.test(str)) throw new Error('bad prefix');
  const buf=unb64url(str.slice(4)), dv=new DataView(buf.buffer,buf.byteOffset,buf.byteLength);
  if(buf.length!==28) throw new Error('bad length');
  let sum=0; for(let i=0;i<27;i++) sum=(sum+buf[i])&255;
  if(sum!==buf[27]) throw new Error('checksum mismatch');
  let o=0; const v=buf[o++]; if(v!==1) throw new Error('version '+v+' unsupported');
  const primary={L:buf[o++]/255, C:buf[o++]/1000, H:(dv.getUint16(o),(o+=2,dv.getUint16(o-2)))};
  const tertiary={L:buf[o++]/255, C:buf[o++]/1000, H:(o+=2,dv.getUint16(o-2))};
  const corners={}; for(const k of ['xs','sm','md','lg','xl','xxl']) corners[k]=buf[o++];
  const displayWeight=buf[o++]*100;
  const displayTracking=dv.getInt8(o)/1000; o+=1;
  const fonts={display:FONTS[buf[o++]], text:FONTS[buf[o++]], num:FONTS[buf[o++]]};
  const loginShell=LOGIN[buf[o++]], dashboardHero=HERO[buf[o++]], contentTone=TONE[buf[o++]], glassTint=GLASS[buf[o++]], motion=MOTION[buf[o++]];
  const f=buf[o++];
  return { version:v, primary, tertiary, corners, displayWeight, displayTracking, fonts,
           loginShell, dashboardHero, contentTone, glassTint, motion,
           defaultDark:!!(f&1), defaultRtl:!!(f&2) };
}
  return { encode: encode, decode: decode, VERSION: 1, registries: { FONTS, LOGIN, HERO, TONE, GLASS, MOTION } };
}));
