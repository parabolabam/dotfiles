"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = void 0;
const vscode = require("vscode");
const fs = require("fs");
const tmp = require("tmp");
const os = require("os");
const opn = require("opn");
const child_process_1 = require("child_process");
/*
 * Called when extension is activated. This happens the very first time the
 * command is executed
 */
function activate(context) {
    // implements command declared in package.json file
    let disposable = vscode.commands.registerCommand('open-in-vim.open', function () {
        try {
            openInVim();
        }
        catch (e) {
            console.error(e);
            vscode.window.showErrorMessage("Open in Vim failed: " + e);
        }
    });
    context.subscriptions.push(disposable);
}
exports.activate = activate;
const PATH_TO_WINDOWS_GIT_SHELL = 'C:\\Program Files\\Git\\bin\\bash.exe';
function getConfiguration() {
    let configuration = Object.assign({}, vscode.workspace.getConfiguration()["open-in-vim"]);
    if (!configuration['integrated-terminal']) {
        configuration['integrated-terminal'] = {};
    }
    if (!configuration['integrated-terminal'].pathToShell) {
        configuration['integrated-terminal'] = Object.assign(Object.assign({}, configuration['integrated-terminal']), { pathToShell: os.type().startsWith('Windows') ? PATH_TO_WINDOWS_GIT_SHELL : '/bin/bash' });
    }
    let openMethodLegacyAliases = [
        ["osx.iterm", "macos.iterm"],
        ["osx.macvim", "macos.macvim"]
    ];
    for (let [legacyValue, newValue] of openMethodLegacyAliases) {
        if (configuration.openMethod === legacyValue) {
            configuration.openMethod = newValue;
        }
    }
    return configuration;
}
function openInVim() {
    const { openMethod, useNeovim, restoreCursorAfterVim } = getConfiguration();
    let activeTextEditor = vscode.window.activeTextEditor;
    if (!activeTextEditor) {
        vscode.window.showErrorMessage('No active editor.');
        return;
    }
    if (activeTextEditor.document.isUntitled) {
        vscode.window.showErrorMessage('Please save the file first.');
        return;
    }
    if (activeTextEditor.document.isDirty) {
        activeTextEditor.document.save();
    }
    let actualOpenMethod = openMethods[openMethod];
    if (!actualOpenMethod) {
        let availableMethods = Object.keys(openMethods).map(name => `"${name}"`).join(", ");
        vscode.window.showErrorMessage(`Check your settings. Method "${openMethod}" is not supported. Currently, you can use ${availableMethods}.`);
        return;
    }
    function getAlternateWorkspacePath() {
        if (vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders.length) {
            // default to first available workspace
            const workspace = vscode.workspace.workspaceFolders[0];
            vscode.window.setStatusBarMessage(`OpenInVim defaulted vim working dir to ${workspace.name}`, 5000);
            return workspace.uri.path;
        }
        else {
            // NO workspaces are open, so just use home
            return os.homedir();
        }
    }
    const workspace = vscode.workspace.getWorkspaceFolder(activeTextEditor.document.uri);
    const workspacePath = workspace ? workspace.uri.path : getAlternateWorkspacePath();
    let position = activeTextEditor.selection.active;
    let fileName = activeTextEditor.document.fileName;
    let line = position.line + 1;
    let column = position.character + 1;
    /** autocmd VimLeavePre * execute "!code --goto '" . expand("%") . ":" . line(".") . ":" . col(".") . "'" */
    let AUTOCMD_TO_SYNC_CURSOR = `'+autocmd VimLeavePre * execute "!code --goto '"'"'" . expand("%") . ":" . line(".") . ":" . col(".") . "'"'"'"'`;
    actualOpenMethod({
        vim: useNeovim ? 'nvim' : 'vim',
        fileName: fileName,
        // cannot contain double quotes
        args: `'+call cursor(${line}, ${column})' ${restoreCursorAfterVim ? AUTOCMD_TO_SYNC_CURSOR : ''}; exit`,
        workspacePath,
    });
}
function openArgsToCommand(openArgs) {
    return `${openArgs.vim} '${openArgs.fileName}' ${openArgs.args}`;
}
/**
 * @param openArgs
 * @returns A filepath to a script that opens vim according to openArgs
 */
function openArgsToScriptFile(openArgs) {
    let tmpFile = tmp.fileSync();
    fs.writeFileSync(tmpFile.name, `
        cd '${openArgs.workspacePath}'
        ${openArgsToCommand(openArgs)}
    `);
    return tmpFile.name;
}
/**
 * example: converts `\C:\test\file.txt` to `/c/test/file.txt`
 *                                       or `/mnt/c/test/file.txt` (for isWslStyle=true)
 */
function ensureUnixPathFormat(path, isWslStyle) {
    if (os.type().startsWith('Windows')) {
        return path
            .replace(/^\/?(\w):/, (str, driveLetter) => `/${isWslStyle ? 'mnt/' : ''}${driveLetter.toLowerCase()}`)
            .replace(/\\/g, '/');
    }
    else {
        return path;
    }
}
const openMethods = {
    "gvim": (openArgs) => {
        if (os.type().startsWith('Windows')) {
            const viewAlternatePlugin = 'View alternative plugin';
            vscode.window.showErrorMessage('Gvim is not supported on Windows. ლ(ಠ_ಠლ)', viewAlternatePlugin).then(choice => {
                if (choice === viewAlternatePlugin) {
                    opn('https://marketplace.visualstudio.com/items?itemName=mattn.OpenVim');
                }
            });
            return;
        }
        openArgs.vim = 'gvim';
        (0, child_process_1.execSync)(openArgsToCommand(openArgs), {
            cwd: openArgs.workspacePath,
            encoding: "utf8"
        });
    },
    "integrated-terminal": (openArgs) => {
        const shellPath = getConfiguration()['integrated-terminal'].pathToShell;
        if (!fs.existsSync(shellPath)) {
            if (os.type().startsWith('Windows') && shellPath === PATH_TO_WINDOWS_GIT_SHELL) {
                const installGit = 'Install Git';
                vscode.window.showErrorMessage(`Failed to find unix shell. If you install Git, open-in-vim can use "${PATH_TO_WINDOWS_GIT_SHELL}".`, installGit).then(choice => {
                    if (choice === installGit) {
                        opn('https://git-scm.com/download/win');
                    }
                });
            }
            else {
                vscode.window.showErrorMessage(`Failed to find unix shell "${shellPath}". Check your settings.`);
            }
            return;
        }
        /** Windows Subsystem for Linux sees different paths than git bash */
        const isWslStyle = os.type().startsWith('Windows') &&
            (0 === require('child_process')
                .spawnSync(shellPath, ['-c', 'test -d /mnt/c'])
                .status);
        openArgs.fileName = ensureUnixPathFormat(openArgs.fileName, isWslStyle);
        openArgs.workspacePath = ensureUnixPathFormat(openArgs.workspacePath, isWslStyle);
        let terminal = vscode.window.createTerminal({
            name: "Open in Vim",
            shellPath,
            shellArgs: [
                ensureUnixPathFormat(openArgsToScriptFile(openArgs), isWslStyle)
            ]
        });
        terminal.show(true);
        vscode.commands.executeCommand("workbench.action.terminal.focus");
    },
    "kitty": (openArgs) => {
        let kittyCommand = `kitty --title 'vscode-open-in-vim' bash '${openArgsToScriptFile(openArgs)}'`;
        console.log(kittyCommand);
        (0, child_process_1.execSync)(kittyCommand);
    },
    "linux.gnome-terminal": (openArgs) => {
        let args = getConfiguration().linux['gnome-terminal'].args;
        let gnomeTerminalCommand = `gnome-terminal ${args} --command='bash ${openArgsToScriptFile(openArgs)}'`;
        (0, child_process_1.execSync)(gnomeTerminalCommand);
    },
    "linux.tilix": (openArgs) => {
        let args = getConfiguration().linux.tilix.args;
        let tilixCommand = `tilix ${args} --command='bash ${openArgsToScriptFile(openArgs)}'`;
        (0, child_process_1.execSync)(tilixCommand);
    },
    "macos.iterm": (openArgs) => {
        let profile = getConfiguration().macos.iterm.profile;
        if (profile !== "default profile") {
            profile = `profile "${profile}"`;
        }
        let osascriptcode = `
            tell application "iTerm"
              set myNewWin to create window with ${profile} command "bash ${openArgsToScriptFile(openArgs)}"
            end tell
        `;
        let result = (0, child_process_1.spawnSync)("/usr/bin/osascript", { encoding: "utf8", input: osascriptcode });
        if (result.error) {
            throw result.error;
        }
        if (result.stderr) {
            throw result.stderr;
        }
    },
    "macos.macvim": (openArgs) => {
        openArgs.vim = 'mvim';
        (0, child_process_1.execSync)(openArgsToCommand(openArgs), {
            cwd: openArgs.workspacePath,
            encoding: "utf8"
        });
    },
};
//# sourceMappingURL=extension.js.map