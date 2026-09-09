import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";

const WORKING_VERBS = [
  "Accomplishing", "Actioning", "Actualizing", "Architecting", "Baking", "Beaming", "Beboppin'", "Befuddling",
  "Billowing", "Blanching", "Bloviating", "Boogieing", "Boondoggling", "Booping", "Bootstrapping", "Brewing",
  "Bunning", "Burrowing", "Calculating", "Canoodling", "Caramelizing", "Cascading", "Catapulting", "Cerebrating",
  "Channeling", "Channelling", "Choreographing", "Churning", "Clauding", "Coalescing", "Cogitating", "Combobulating",
  "Composing", "Computing", "Concocting", "Considering", "Contemplating", "Cooking", "Crafting", "Creating",
  "Crunching", "Crystallizing", "Cultivating", "Deciphering", "Deliberating", "Determining", "Dilly-dallying",
  "Discombobulating", "Doing", "Doodling", "Drizzling", "Ebbing", "Effecting", "Elucidating", "Embellishing",
  "Enchanting", "Envisioning", "Fermenting", "Fiddle-faddling", "Finagling", "Flambéing", "Flibbertigibbeting",
  "Flowing", "Flummoxing", "Fluttering", "Forging", "Forming", "Frolicking", "Frosting", "Gallivanting", "Galloping",
  "Garnishing", "Generating", "Gesticulating", "Germinating", "Gitifying", "Grooving", "Gusting", "Harmonizing",
  "Hashing", "Hatching", "Herding", "Honking", "Hullaballooing", "Hyperspacing", "Ideating", "Imagining",
  "Improvising", "Incubating", "Inferring", "Infusing", "Ionizing", "Jitterbugging", "Julienning", "Kneading",
  "Leavening", "Levitating", "Lollygagging", "Manifesting", "Marinating", "Meandering", "Metamorphosing", "Misting",
  "Moonwalking", "Moseying", "Mulling", "Mustering", "Musing", "Nebulizing", "Nesting", "Newspapering", "Noodling",
  "Nucleating", "Orbiting", "Orchestrating", "Osmosing", "Perambulating", "Percolating", "Perusing", "Philosophising",
  "Photosynthesizing", "Pollinating", "Pondering", "Pontificating", "Pouncing", "Precipitating", "Prestidigitating",
  "Processing", "Proofing", "Propagating", "Puttering", "Puzzling", "Quantumizing", "Razzle-dazzling", "Razzmatazzing",
  "Recombobulating", "Reticulating", "Roosting", "Ruminating", "Sautéing", "Scampering", "Schlepping", "Scurrying",
  "Seasoning", "Shenaniganing", "Shimmying", "Simmering", "Skedaddling", "Sketching", "Slithering", "Smooshing",
  "Sock-hopping", "Spelunking", "Spinning", "Sprouting", "Stewing", "Sublimating", "Swirling", "Swooping", "Symbioting",
  "Synthesizing", "Tempering", "Thinking", "Thundering", "Tinkering", "Tomfoolering", "Topsy-turvying", "Transfiguring",
  "Transmuting", "Twisting", "Undulating", "Unfurling", "Unravelling", "Vibing", "Waddling", "Wandering", "Warping",
  "Whatchamacalliting", "Whirlpooling", "Whirring", "Whisking", "Wibbling", "Working", "Wrangling", "Zesting", "Zigzagging",
] as const;

function indicatorColor(theme: Theme, text: string): string {
  const match = /38;2;(\d+);(\d+);(\d+)/.exec(theme.getFgAnsi("text"));
  if (!match) return theme.fg("text", text);

  const [r, g, b] = [Number(match[1]), Number(match[2]), Number(match[3])];
  const textLuminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  const rgb = textLuminance < 0.5 ? "0;0;0" : "255;255;255";
  return `\x1b[38;2;${rgb}m${text}\x1b[39m`;
}

export default function (pi: ExtensionAPI) {
  let previousVerb: string | undefined;
  let verbRefreshTimer: ReturnType<typeof setTimeout> | undefined;

  const chooseVerb = () => {
    let verb: string;
    do {
      verb = WORKING_VERBS[Math.floor(Math.random() * WORKING_VERBS.length)]!;
    } while (verb === previousVerb);
    previousVerb = verb;
    return verb;
  };
  pi.on("session_start", (_event, ctx) => {
    const frame = (text: string) => indicatorColor(ctx.ui.theme, text);

    ctx.ui.setWorkingIndicator({
      frames: [
        frame("●∙∙"),
        frame("∙●∙"),
        frame("∙∙●"),
        frame("∙●∙"),
      ],
      intervalMs: 180,
    });
  });

  pi.on("agent_start", (_event, ctx) => {
    if (verbRefreshTimer) clearTimeout(verbRefreshTimer);
    ctx.ui.setWorkingMessage(indicatorColor(ctx.ui.theme, `${chooseVerb()}…`));

    verbRefreshTimer = setTimeout(() => {
      ctx.ui.setWorkingMessage(indicatorColor(ctx.ui.theme, `${chooseVerb()}…`));
      verbRefreshTimer = undefined;
    }, 1_000);
  });

  pi.on("agent_settled", () => {
    if (verbRefreshTimer) clearTimeout(verbRefreshTimer);
    verbRefreshTimer = undefined;
  });

  pi.on("session_shutdown", () => {
    if (verbRefreshTimer) clearTimeout(verbRefreshTimer);
    verbRefreshTimer = undefined;
  });
}
