"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getLeftMostHintOfLine = exports.createInlayHint = exports.quickInfoRequest = void 0;
const vscode = require("vscode");
/** Leverages the `tsserver` protocol to try to get the type info at the given `position`. */
async function quickInfoRequest(model, position) {
    const { scheme, fsPath, authority, path } = model.uri;
    return await vscode.commands.executeCommand("typescript.tsserverRequest", "quickinfo", {
        file: scheme === 'file' ? fsPath : `^/${scheme}/${authority || 'ts-nul-authority'}/${path.replace(/^\//, '')}`,
        line: position.line + 1,
        offset: position.character,
    });
}
exports.quickInfoRequest = quickInfoRequest;
/** Creates a `vscode.InlayHint` to display a `QuickInfo` response. */
function createInlayHint({ hint, position, lineLength = 0 }) {
    if (!hint || !hint.body) {
        return;
    }
    // Make a one-liner
    let text = hint.body.displayString
        .replace(/\\n/g, " ")
        .replace(/\/n/g, " ")
        .replace(/  /g, " ")
        .replace(/[\u0000-\u001F\u007F-\u009F]/g, "");
    // Cut off hint if too long
    // If microsoft/vscode#174159 lands, can change to check that
    const availableSpace = 120 - lineLength;
    if (text.length > availableSpace) {
        text = text.slice(0, availableSpace - 1) + "...";
    }
    return {
        kind: vscode.InlayHintKind.Type,
        position: position.translate(0, 1),
        label: text,
        paddingLeft: true,
    };
}
exports.createInlayHint = createInlayHint;
const range = (num) => [...Array(num).keys()];
/** Gets the first `QuickInfo` response in a given line, if available. */
async function getLeftMostHintOfLine({ model, position, lineLength }) {
    for (const i of range(lineLength)) {
        const hint = await quickInfoRequest(model, position.translate(0, i));
        if (!hint || !hint.body) {
            continue;
        }
        return hint;
    }
}
exports.getLeftMostHintOfLine = getLeftMostHintOfLine;
//# sourceMappingURL=helpers.js.map