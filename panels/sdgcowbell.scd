// panels/sdgcowbell.scd - what the cowbell's window shows (SynthVoiceWindow): the 808's two
// squares through the tone filter, the pair as a wave, the strike and its tail.
(
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var tuneOf = { |p| 2 ** (((p[\note] ? 0) + (p[\sdgtune] ? 0)) / 12) };
var f1 = { |p| 558 * tuneOf.(p) };
var f2 = { |p| f1.(p) * (1 + p[\sdgcolor].clip(0.05, 1)) };
var lp = { |p| p[\sdgtone].linexp(0, 1, 1000, 9000) * tuneOf.(p).clip(0.25, 4).sqrt };
// two one-pole-pair low passes: 24 dB an octave above the tone frequency
var att = { |f, p| 1 / (1 + ((f / lp.(p)) ** 4)) };
var hpf = { |f, p| var c = (f1.(p) * 0.7).max(150); 1 / (1 + ((c / f) ** 4)) };
var db = { |v| (v.max(1e-4).ampdb + 48 / 48).clip(0, 1) };
var sq = { |f, t, p| var s = 0; 9.do { |i| var k = (2 * i) + 1; s = s + (sin(2pi * k * f * t) * att.(k * f, p) / k) }; s * 4 / pi };
// the 808's VCA: up in 0.5 ms, the strike falls to 1 - 0.9 click in 12 ms (curve -3), then the tail (curve -5)
var seg = { |u, c| (1 - exp(c * u.clip(0, 1))) / (1 - exp(c)) };
var vca = { |t, p| var lo = 1 - (p[\sdgclick] * 0.9);
	case { t < 0.0005 } { t / 0.0005 } { t < 0.0125 } { 1 - ((1 - lo) * seg.((t - 0.0005) / 0.012, -3)) } { lo * (1 - seg.((t - 0.0125) / p[\sdgdecay], -5)) } };
(
	colour: \gold, drum: true,
	hint: "interval - the upper square is 1 + interval times the lower: 0.48 the 808, 0.5 a fifth, 1 an octave",
	panes: [
		(type: \partials, w: 1.2, title: "two squares", lo: 200, hi: 16000,
			list: { |p| var a = f1.(p), b = f2.(p), m = p[\sdgmetal];
				(5.collect { |i| var k = (2 * i) + 1; (hz: a * k, level: db.(0.3 * (1 - m) / k * att.(a * k, p) * hpf.(a * k, p)), label: if(i == 0) { "low" }) }
				++ 5.collect { |i| var k = (2 * i) + 1; (hz: b * k, level: db.((1 - m) / k * att.(b * k, p) * hpf.(b * k, p)), colour: \wave, label: if(i == 0) { "high" }) }
				++ if(m > 0.02) { [b - a, b + a].collect { |f| (hz: f, level: db.(m * 1.25 * att.(f, p) * hpf.(f, p)), colour: \dim, width: 2, label: "ring") } } { [] })
				.reject { |e| e[\level] <= 0.01 } },
			readout: { |p| "% and % · %".format(SynthVoicePanes.format(f1.(p), "Hz"), SynthVoicePanes.format(f2.(p), "Hz"), SynthVoicePanes.noteName(f2.(p))) }),
		(type: \wave, w: 0.8, title: "the pair", cycles: 1,
			func: { |ph, p| var t = ph * 4 / f1.(p), a = sq.(f1.(p), t, p), b = sq.(f2.(p), t, p), m = p[\sdgmetal];
				((((a * 0.3) + b) * (1 - m)) + (a * b * m * 2.5)) * 0.62 },
			label: "four of the low cycles", readout: { |p| "tone % · clank %".format(pct.(p[\sdgtone]), pct.(p[\sdgmetal])) }),
		(type: \env, w: 1.0, title: "strike and tail", len: { |p| p[\sdgdecay] * 1.05 + 0.0125 },
			// the first 12 ms take the first 8 % of the width, or the strike falls between the points drawn
			curves: { |p| var len = p[\sdgdecay] * 1.05 + 0.0125, k = len * 0.08;
				[(func: { |t| vca.(if(t < k) { t / k * 0.0125 } { 0.0125 + ((t - k) / (len - k) * (len - 0.0125)) }, p) }, label: "level, the strike drawn wide")] },
			readout: { |p| "strike % over the tail · % to silence".format(pct.(p[\sdgclick]), SynthVoicePanes.format(p[\sdgdecay] + 0.0125, "s")) })
	],
	macros: [
		(name: "brightness", text: "tone and strike", targets: [[\sdgtone, 0.4], [\sdgclick, 0.3]]),
		(name: "timbre", text: "clank, a brighter edge", targets: [[\sdgmetal, 0.45], [\sdgtone, 0.2]]),
		(name: "time", text: "the tail", targets: [[\sdgdecay, 0.45]]),
		(name: "movement", text: "the interval and the ring", targets: [[\sdgcolor, 0.35], [\sdgmetal, 0.3]])
	],
	cards: [
		(title: "pair", knobs: [(key: \sdgcolor, label: "interval", spec: ControlSpec(0.05, 1, \lin, 0, 0.476, "x"), dec: 2, sub: "0.48 the 808")]),
		(title: "hit", knobs: [
			(key: \sdgmetal, label: "clank", spec: ControlSpec(0, 1), box: \pct, sub: "rung together"),
			(key: \sdgclick, label: "click", spec: ControlSpec(0, 1), box: \pct, sub: "first 12 ms")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgtune, label: "tune", size: \big, spec: ControlSpec(-24, 24, \lin, 0, 0, "st"), sub: "from 558 Hz", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.05, 3, \exp, 0, 0.6, "s"), sub: "the tail"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	]
)
)
