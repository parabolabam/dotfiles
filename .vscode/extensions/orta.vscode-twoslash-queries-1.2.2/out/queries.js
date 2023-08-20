"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getHintsFromQueries = void 0;
const helpers_1 = require("./helpers");
const twoslashQueryRegex = /^\s*\/\/\.?\s*\^\?/gm; // symbol: ^?
// https://regex101.com/r/6Jb8h2/1
const inlineQueryRegex = /^[^\S\r\n]*(?<start>\S).*\/\/\s*(?<end>=>)/gm; // symbol: =>
/** Checks for and returns regular two-slash query hints (symbol: ^?). */
async function checkTwoslashQuery({ text, offset, model, cancel }) {
    const results = [];
    const m = text.matchAll(twoslashQueryRegex);
    for (const match of m) {
        if (match.index === undefined) {
            break;
        }
        const end = match.index + match[0].length - 1;
        // Add the start range for the inlay hint
        const endPos = model.positionAt(end + offset);
        if (cancel.isCancellationRequested) {
            return [];
        }
        const hint = await (0, helpers_1.quickInfoRequest)(model, endPos.translate(-1));
        const inlayHint = (0, helpers_1.createInlayHint)({ hint, position: endPos });
        if (inlayHint) {
            results.push(inlayHint);
        }
    }
    return results;
}
/** Checks for and returns inline query hints (symbol: =>). */
async function checkInlineQuery({ text, offset, model, cancel }) {
    const results = [];
    const m = text.matchAll(inlineQueryRegex);
    for (const match of m) {
        if (match.index === undefined) {
            break;
        }
        if (cancel.isCancellationRequested) {
            return [];
        }
        const [line] = match;
        const { start, end: querySymbol } = match.groups;
        const startIndex = line.indexOf(start);
        const startPos = model.positionAt(startIndex + offset + match.index);
        const endIndex = line.lastIndexOf(querySymbol) + 2;
        const endPos = model.positionAt(endIndex + offset + match.index);
        const hint = await (0, helpers_1.getLeftMostHintOfLine)({ model, position: startPos, lineLength: endIndex - startIndex - 2 });
        const inlayHint = (0, helpers_1.createInlayHint)({ hint, position: endPos, lineLength: line.length });
        if (inlayHint) {
            results.push(inlayHint);
        }
    }
    return results;
}
/** Sequentially checks each type of query for hints to display. */
async function getHintsFromQueries(queryInfo) {
    const queries = [checkTwoslashQuery, checkInlineQuery];
    const results = [];
    for (const query of queries) {
        const queryResults = await query(queryInfo);
        results.push(...queryResults);
    }
    return results;
}
exports.getHintsFromQueries = getHintsFromQueries;
//# sourceMappingURL=queries.js.map