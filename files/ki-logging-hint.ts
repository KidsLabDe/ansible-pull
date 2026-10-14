import { Plugin } from "@opencode/plugin/tui"

// Zeigt beim Start von OpenCode einen Hinweis auf die aktive Logging-Instanz.
// Wird von Ansible nach ~/.config/opencode/plugins/ deployt und dort
// automatisch geladen (keine Eintragung in der Config noetig).

const MESSAGE =
  "Deine Anfragen werden geloggt und andere koennen sie sehen, um zu lernen. " +
  "Wenn du das nicht magst, schalte bitte per /model auf 'Qwen (ohne Log)' um."

export default Plugin.define({
  id: "kidslab.logging-hint",
  setup(context) {
    context.ui.toast.show({
      title: "Info: Logging aktiv",
      message: MESSAGE,
      duration: 12000,
    })
  },
})
