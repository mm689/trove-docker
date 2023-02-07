
const ansiRegex = require('ansi-regex');
var assert = require('assert');
assert(ansiRegex().test('\u001B[4mcake\u001B[0m'));

const graphviz = require('graphviz')
const graph = graphviz.digraph()
graph.addNode('node1')

const confirmSvg = (data) => {
    const svg = data.toString()
    if (!svg.includes('<g id="node1" class="node">')) {
        throw Error('SVG does not appear to be valid')
    }
}
graph.render({ use: 'dot', type: 'svg' }, confirmSvg)