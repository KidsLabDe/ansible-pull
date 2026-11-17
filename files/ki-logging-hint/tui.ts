import { Plugin } from "@opencode/plugin/tui"

// Zeigt beim Start von OpenCode einen Datenschutz-Hinweis: Inhalte werden
// nicht gespeichert, nur Metadaten (siehe Datenschutzseite auf ki.kidslab.de).
// Wird von Ansible nach ~/.config/opencode/plugins/ deployt und dort
// automatisch geladen (keine Eintragung in der Config noetig).

const MESSAGE =
  "Deine Prompts und die Antworten werden nicht gespeichert. Der Server notiert " +
  "nur Zahlen (Zeit, Programm, Tokens). Deine Statistik: https://ki.kidslab.de"

export default Plugin.define({
  id: "kidslab.logging-hint",
  setup(context) {
    context.ui.toast.show({
      title: "Info: Datenschutz",
      message: MESSAGE,
      duration: 12000,
    })
  },
})
