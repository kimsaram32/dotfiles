import * as K from "karabiner.ts";

const App = {
  emacs: "org.gnu.Emacs",
};

function modifiers() {
  const ifEmacs = K.ifApp({ bundle_identifiers: [App.emacs] });

  return K.rule("Modifiers").manipulators([
    K.map("left_command", "", "any").to("left_option"),
    K.map("fn", "", "any").to("left_command"),
    K.map("caps_lock", "", "any").to("left_control").condition(ifEmacs),

    K.map("caps_lock", "", "any")
      .to("left_command")
      .condition(ifEmacs.unless()),
  ]);
}

// I remapped left_cmd + f12 to change input source in macOS settings.
function input() {
  return K.rule("Input").manipulators([
    K.map("right_command").to("f12", "left_command"),
  ]);
}

function colemak() {
  const colemakVar = "colemak";

  // prettier-ignore
  const colemakMapper = {
    /* q */ /* w */ e: 'f', r: 'p', t: 'b', y: 'j', u: 'l', i: 'u', o: 'y', p: ';',
    /* a */ s: 'r', d: 's', f: 't', /* g */ h: 'm', j: 'n', k: 'e', l: 'i', ';': 'o',
    /* z */ /* x */ /* c */ v: 'd', b: 'v', n: 'k', m: 'h',
  } as const;

  const ifColemak = K.ifVar(colemakVar, true);
  const ifEn = K.ifInputSource({ language: "en" });

  return K.rule("Colemak").manipulators([
    K.map("k", ["left_command", "left_control"])
      .toVar(colemakVar, true)
      .condition(ifColemak.unless()),

    K.map("k", ["left_command", "left_control"])
      .toUnsetVar(colemakVar)
      .condition(ifColemak),

    K.withCondition(
      ifColemak,
      ifEn,
    )([K.withMapper(colemakMapper)((k, v) => K.map(k, "", "any").to(v))]),
  ]);
}

K.writeToProfile("Default profile", [modifiers(), input(), colemak()]);
