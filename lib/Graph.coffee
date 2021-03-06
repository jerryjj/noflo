fs = require "fs"
events = require "events"

class Graph extends events.EventEmitter
    name: ""
    nodes: []
    edges: []
    initializers: []

    constructor: (name) ->
        @nodes = []
        @edges = []
        @initializers = []
        @name = name

    addNode: (id, component) ->
        node =
            id: id
            component: component
        @nodes.push node
        @emit "addNode", node

    removeNode: (id) ->
        @emit "removeNode", node

        for edge in @edges
            if edge.from.node is node.id
                @removeEdge edge
            if edge.to.node is node.id
                @removeEdge edge

        if @nodes.indexOf node isnt -1
            delete @nodes[@nodes.indexOf node]

    getNode: (id) ->
        for node in @nodes
            if node.id is id
                return node

    addEdge: (outNode, outPort, inNode, inPort) ->
        edge =
            from:
                node: outNode
                port: outPort
            to:
                node: inNode
                port: inPort
        @edges.push edge
        @emit "addEdge", edge

    removeEdge: (node, port) ->
        for edge,index in @edges
            if edge.from.node is node and edge.from.port is port
                @emit "removeEdge", edge
                delete @edges[index]
            if edge.to.node is node and edge.to.port is port
                @emit "removeEdge", edfe
                delete @edges[index]

    addInitial: (data, node, port) ->
        initializer =
            from:
                data: data
            to:
                node: node
                port: port
        @initializers.push initializer
        @emit "addInitial", initializer

    toDOT: ->
        cleanID = (id) ->
            id.replace /\s*/g, ""

        dot = "digraph {\n"

        for node in @nodes
            dot += "    #{cleanID(node.id)} [shape=box]\n"

        for initializer, id in @initializers
            dot += "    data#{id} -> #{cleanID(initializer.to.node)} [label='#{initializer.to.port}']\n" 

        for edge in @edges
            continue unless edge
            dot += "    #{cleanID(edge.from.node)} -> #{cleanID(edge.to.node)}[label='#{edge.from.port}']\n"

        dot += "}"

        return dot

    toYUML: ->
        yuml = []

        for initializer in @initializers
            yuml.push "(start)[#{initializer.to.port}]->(#{initializer.to.node})";

        for edge in @edges
            yuml.push "(#{edge.from.node})[#{edge.from.port}]->(#{edge.to.node})"
        yuml.join ","

exports.createGraph = (name) ->
    new Graph name

exports.loadFile = (file, success) ->
    fs.readFile "#{file}.json", "utf-8", (err, data) ->
        throw err if err

        definition = JSON.parse data

        graph = new Graph definition.properties.name

        for id, def of definition.processes
            graph.addNode id, def.component

        for conn in definition.connections
            if conn.data
                graph.addInitial conn.data, conn.tgt.process, conn.tgt.port
                continue
            graph.addEdge conn.src.process, conn.src.port, conn.tgt.process, conn.tgt.port

        success graph
