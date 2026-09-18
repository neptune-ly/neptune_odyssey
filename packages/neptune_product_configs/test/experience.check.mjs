// Dependency-free checks for the additive experience module. Existing Vitest tests remain unchanged.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const temp = mkdtempSync(join(tmpdir(), 'odyssey-experience-'));
const results = [];
let failed = 0;
const check = (name, test) => { try { test(); results.push({ name, passed: true }); } catch (error) { failed++; results.push({ name, passed: false, error: error.message }); } };
try {
  const source = fileURLToPath(new URL('../src/experience.ts', import.meta.url));
  const compile = spawnSync(process.platform === 'win32' ? 'tsc.cmd' : 'tsc', [source, '--target', 'ES2022', '--module', 'ES2022', '--moduleResolution', 'Bundler', '--strict', '--skipLibCheck', '--outDir', temp], { encoding: 'utf8' });
  if (compile.error || compile.status !== 0) throw new Error(`TypeScript compilation failed: ${compile.error ?? compile.stderr ?? compile.stdout}`);
  writeFileSync(join(temp, 'package.json'), '{"type":"module"}');
  const m = await import(pathToFileURL(join(temp, 'experience.js')).href);
  const request = { product: 'travel', world: 'horizon', brandprint: 'host-owned-demo' };
  const money = (minor, currency = 'LYD', scale = 3) => ({ minor, currency, scale });
  const event = (type, authority = 'provider', reference = 'DEMO-REF') => ({ type, authority, reference });
  check('Original six visual worlds preserved', () => assert.deepEqual(m.VISUAL_WORLDS, ['orbit','current','bloom','atelier','signal','horizon']));
  check('Twelve product grammars exist independently of visual worlds', () => assert.equal(Object.keys(m.PRODUCT_GRAMMARS).length, 12));
  for (const [id, grammar] of Object.entries(m.PRODUCT_GRAMMARS)) {
    check(`${id}: unique destinations, bilingual labels and immutable recipe`, () => {
      assert.equal(new Set(grammar.navigation.map(x => x.id)).size, grammar.navigation.length);
      assert.ok(grammar.navigation.every(x => x.label.en.trim() && x.label.ar.trim()));
      assert.ok(Object.isFrozen(grammar) && Object.isFrozen(grammar.navigation));
      assert.ok(Object.isFrozen(grammar.navigation[0].label));
      for (const world of m.VISUAL_WORLDS) assert.equal(m.resolveExperience({ ...request, product: id, world }).primaryObject, grammar.primaryObject);
    });
  }
  check('Inherited object keys are not product IDs', () => ['constructor','__proto__','toString',null,42].forEach(x => assert.equal(m.isProductGrammarId(x), false)));
  check('Unknown product, world and empty brandprint rejected', () => {
    assert.throws(() => m.getProductGrammar('missing'));
    assert.throws(() => m.resolveExperience({ ...request, world: 'travel' }));
    assert.throws(() => m.resolveExperience({ ...request, brandprint: ' ' }));
  });
  check('Invalid locale and appearance rejected', () => {
    assert.throws(() => m.resolveExperience({ ...request, locale: 'xx' }));
    assert.throws(() => m.resolveExperience({ ...request, mode: 'inverted' }));
  });
  check('Provider capabilities fail closed by default', () => assert.deepEqual(m.resolveExperience(request).enabledCapabilities, []));
  check('Only known own Boolean true flags enable features', () => {
    const capabilities = Object.assign(Object.create({ stays: true }), { flights: true, activities: 'yes', unknown: true });
    assert.deepEqual(m.resolveExperience({ ...request, capabilities }).enabledCapabilities, ['flights']);
  });
  check('Arabic structure keeps independent numeric and geographic orientation', () => {
    const x = m.resolveExperience({ ...request, locale: 'ar' });
    assert.equal(x.direction, 'rtl'); assert.equal(x.navigation[0].label, 'اكتشف');
    assert.ok(x.preserveDirection.includes('geography') && x.preserveDirection.includes('qr'));
  });
  for (const context of ['confirmation','security','driver-navigation']) {
    check(`${context}: expressive requests cannot override restrained motion`, () => {
      const x = m.motionPolicy(context, 'expressive', false);
      assert.equal(x.level, 'restrained'); assert.equal(x.decorativeMotion, false); assert.equal(x.continuousMotion, false);
    });
  }
  check('Reduced-motion mode removes decorative motion', () => {
    const x = m.motionPolicy('discovery', 'expressive', true);
    assert.equal(x.mode, 'Reduced'); assert.equal(x.decorativeMotion, false);
  });
  check('Motion tokens reuse the existing Odyssey scale', () => assert.equal(m.motionPolicy('discovery', 'expressive', false).durationToken, 'o2/motion/expressive'));
  check('Unknown motion values rejected', () => assert.throws(() => m.motionPolicy('random', 'expressive', false)));
  check('LYD three-decimal amount formatted exactly', () => assert.equal(m.formatMoney(money(1250000n)).amount, '1,250.000'));
  check('Very large integer amounts preserve every digit', () => assert.equal(m.formatMoney(money(9007199254740993123n)).amount, '9,007,199,254,740,993.123'));
  check('Negative and zero amounts remain explicit', () => {
    assert.equal(m.formatMoney(money(-1n)).amount, '-0.001');
    assert.equal(m.formatMoney(money(0n)).amount, '0.000');
  });
  check('Zero-decimal currencies are supported without a fraction', () => assert.equal(m.formatMoney(money(1234n, 'JPY', 0)).amount, '1,234'));
  check('Arabic digits retain an isolated LTR amount field', () => {
    const x = m.formatMoney(money(1250000n), 'ar-EG');
    assert.ok(x.amount.includes('١')); assert.equal(x.direction, 'ltr'); assert.equal(x.currency, 'LYD');
  });
  check('Floating-point money and invalid currency precision are rejected', () => {
    assert.throws(() => m.formatMoney(money(1.23)));
    assert.throws(() => m.formatMoney(money(1n, 'LYD', 1.5)));
    assert.throws(() => m.formatMoney(money(1n, 'lyd')));
  });
  check('Fees plus fare reconcile exactly', () => assert.equal(m.sumMoney([money(16000n), money(2000n)]).minor, 18000n));
  check('Mixed currencies and scales cannot be added', () => {
    assert.throws(() => m.sumMoney([money(1n), money(1n, 'USD')]));
    assert.throws(() => m.sumMoney([money(1n), money(1n, 'LYD', 2)]));
    assert.throws(() => m.sumMoney([]));
  });
  const quote = { id: 'QUOTE-1', expiresAtMs: 2000, items: [money(16000n),money(2000n)] };
  check('Fresh quotes return an exact total', () => assert.equal(m.reviewQuote(quote, 1999).minor, 18000n));
  check('Quotes expire at the exact boundary', () => assert.throws(() => m.reviewQuote(quote, 2000)));
  check('Malformed clocks and negative purchase lines rejected', () => {
    assert.throws(() => m.reviewQuote(quote, NaN));
    assert.throws(() => m.reviewQuote({ ...quote, items: [money(-1n)] }, 1000));
    assert.throws(() => m.reviewQuote({ ...quote, id: '' }, 1000));
  });
  check('Booking payment authorization is pending, not booked', () => assert.equal(m.transitionJourney('booking','submitting',event('PAYMENT_AUTHORIZED')), 'pending'));
  check('Provider confirmation and reference are both required', () => {
    assert.throws(() => m.transitionJourney('booking','pending',event('CONFIRMED','user')));
    assert.throws(() => m.transitionJourney('booking','pending',{ type:'CONFIRMED', authority:'provider' }));
    assert.equal(m.transitionJourney('booking','pending',event('CONFIRMED')), 'confirmed');
  });
  check('Unknown outcomes cannot be blindly resubmitted', () => {
    for (const kind of ['booking','order','payout']) assert.throws(() => m.transitionJourney(kind,'unknown',event('SUBMIT','user')));
    assert.throws(() => m.transitionJourney('ride','unknown',event('REQUEST','user')));
  });
  check('Provider inquiry can resolve an unknown booking', () => assert.equal(m.transitionJourney('booking','unknown',event('CONFIRMED')), 'confirmed'));
  check('Cancellation request is not cancellation completion', () => {
    assert.equal(m.transitionJourney('booking','confirmed',event('CANCEL','user')), 'cancel_requested');
    assert.equal(m.transitionJourney('booking','cancel_requested',event('CANCELLED')), 'cancelled');
  });
  check('Cancelled booking is not silently labelled refunded', () => {
    assert.throws(() => m.transitionJourney('booking','cancelled',event('REFUNDED')));
    assert.equal(m.transitionJourney('booking','refund_pending',event('REFUNDED')), 'refunded');
  });
  check('Ride request is searching, not a matched driver', () => assert.equal(m.transitionJourney('ride','quoted',event('REQUEST','user')), 'searching'));
  check('Ride cannot complete before it starts', () => assert.throws(() => m.transitionJourney('ride','arriving',event('COMPLETED'))));
  check('Confirmed backend state can reconcile a disconnected ride', () => assert.equal(m.transitionJourney('ride','unknown',event('COMPLETED')), 'completed'));
  check('Order confirmation is not delivery', () => {
    assert.throws(() => m.transitionJourney('order','confirmed',event('DELIVERED')));
    assert.equal(m.transitionJourney('order','in_transit',event('DELIVERED')), 'delivered');
  });
  check('Payout submission stays pending until paid', () => {
    assert.equal(m.transitionJourney('payout','quoted',event('SUBMIT','user')), 'pending');
    assert.equal(m.transitionJourney('payout','pending',event('PAID')), 'confirmed');
  });
  check('Unknown journey kinds and prototype property names rejected', () => {
    assert.throws(() => m.transitionJourney('constructor','draft',event('CONFIRMED')));
    assert.throws(() => m.transitionJourney('booking','draft',event('__proto__')));
  });
  check('Completed outcomes cannot regress to network unknown', () => assert.throws(() => m.transitionJourney('booking','confirmed',event('TIMEOUT','device'))));
  check('Pending and refund-pending are explicitly uncertain', () => {
    ['pending','unknown','submitting','refund_pending','searching'].forEach(s => assert.equal(m.isOutcomeUncertain(s), true));
    assert.equal(m.isOutcomeUncertain('confirmed'), false);
  });
  console.log(JSON.stringify({ typecheck: 'passed', total: results.length, passed: results.length - failed, failed, results }, null, 2));
  if (failed) process.exitCode = 1;
} finally { rmSync(temp, { recursive: true, force: true }); }
