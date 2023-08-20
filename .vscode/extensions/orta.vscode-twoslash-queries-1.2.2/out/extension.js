"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
const vscode = require("vscode");
const queries_1 = require("./queries");
function activate(context) {
    registerInlayHintsProvider(context);
    registerInsertTwoSlashQueryCommand(context);
}
exports.activate = activate;
function deactivate() { }
exports.deactivate = deactivate;
function registerInlayHintsProvider(context) {
    const provider = {
        provideInlayHints: async (model, iRange, cancel) => {
            const offset = model.offsetAt(iRange.start);
            const text = model.getText(iRange);
            return await (0, queries_1.getHintsFromQueries)({ text, offset, model, cancel });
        },
    };
    context.subscriptions.push(vscode.languages.registerInlayHintsProvider([{ language: "javascript" }, { language: "typescript" }, { language: "typescriptreact" }, { language: "javascriptreact" }], provider));
}
function registerInsertTwoSlashQueryCommand(context) {
    context.subscriptions.push(vscode.commands.registerTextEditorCommand('orta.vscode-twoslash-queries.insert-twoslash-query', (textEditor) => {
        const { document, selection: { end, active } } = textEditor;
        const eolRange = document.lineAt(end.line).range.end;
        const comment = '//'.padEnd(active.character, ' ').concat('^?');
        textEditor.edit(editBuilder => {
            const eolChar = document.eol === vscode.EndOfLine.LF ? '\n' : '\r\n';
            editBuilder.insert(eolRange, eolChar + comment);
        });
    }));
}
//# sourceMappingURL=extension.js.map