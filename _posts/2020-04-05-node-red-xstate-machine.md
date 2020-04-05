---
layout: post
title: Using state charts and finite state-machines in node-red
categories: 
   - node-red 
   - state charts 
   - fsm 
   - state machines 
   - xstate 
   - state-machine-cat
comments: true
---

I have been using [node-red](https://nodered.org/) running on a raspberry pi 3 for two years now in order to control my custom cloudless smart-home system. While this node.js based software package allows for easy drag&click programming of message based flows it always bugged me that it is quite user-unfriendly to create systems that keep track of their state and react to external events. It is exactly where [state machines](https://en.wikipedia.org/wiki/UML_state_machine) should come into play.

While there are some node-red extension packages available, such as
 - [node-red-contrib-finite-statemachine](https://www.npmjs.com/package/node-red-contrib-finite-statemachine) which offers a basic visualization of your machine but still depends on having the largest part of your machine's logic to be implemented externally in node-red (and thus creating yet again very complex flows)
 - [node-red-contrib-state-machine](https://www.npmjs.com/package/node-red-contrib-state-machine) which is a wrapper around the [javascript state machine package](https://www.npmjs.com/package/javascript-state-machine). Still this lacks intrinsically defined delayed events and nested/compound/parallel states.

none of those had the functionality or user experience I had in mind.

After I had found the very well documented, flexible and well maintained node.js package [xstate](https://xstate.js.org/docs/) that intrinsically offers, at least as far as I can tell, all the functionality needed for modeling [OMG UML](https://www.omg.org/spec/PSSM/About-PSSM/) conform state-machines, I was motivated to write my own [node-red extension package][1].

One huge point for me is state-machine visualization. Because state-machines have a strict form it is possible to take a state-machine design and express it in a picture. This gives you an overview of all the functionality of such a machine at a glance and allows you to quickly comprehend what is going on. I had to try lots of available packages such as
 - [dagre-d3](https://github.com/dagrejs/dagre-d3) - uses [dagre](https://github.com/dagrejs/dagre) for layouting which is a rewrite of graphviz
 - [cytoscape](https://cytoscape.org/) with different layouting extensions such as [cose-bilkent](https://github.com/cytoscape/cytoscape.js-cose-bilkent). One (failed) try to render a state-machine is shown below. I couldn't get the labels to work correctly without spending too much time on the cytoscape implementation code.
 - [mxGraph](https://github.com/jgraph/mxgraph) (not really open-source)
 - [webcola](https://ialab.it.monash.edu/webcola/) - development seems to have stopped
 
 but all had some disadvantages, mainly in layouting nested graphs or considering label sizes for layouting. I was ready to give up the search and start developing my own package until I found the excellent [state-machine-cat 😺][2] node.js package that currently utilizes [viz.js](https://github.com/mdaines/viz.js) (a port to node.js of the 1991 [graphviz](https://www.graphviz.org/)) as its layouting and rendering core. This offered all the functions I had in mind (well, except for the one I mentioned in [issue #116](https://github.com/sverweij/state-machine-cat/issues/116) - I had to incorporate a nasty workaround) and on top of that is very well documented and easy to use.

Here is a comparison of the output from state-machine-cat versus cytoscape (that I hacked together):
<p align="center">state-machine-cat render<br><img src="/assets/smcat_fsm.png" alt="Render of state machine with state-machine-cat"></p>
<p align="center">cytoscape render using the cose-bilkent layouting<br><img src="/assets/cytoscape_fsm.png" alt="One (failed) try to render state machine with cytoscape"></p>

[State-machine-cat][2] is pretty nifty, isn't it?

## How it works

Are you still there? Excellent! Install the node-red package simply by searching `node-red-contrib-xstate-machine` in the palette manager. 

Alternatively you can run the command

    npm install node-red-contrib-xstate-machine

in your node-red settings folder (usually `~/.node-red`)

To get you started check out the documentation over at [npmjs][1]. If you want to contribute to the project, have a look at [github][3]. I'm always happy about input and suggestions.

[1]: https://www.npmjs.com/package/node-red-contrib-xstate-machine "Node-RED State-machine package"
[2]: https://github.com/sverweij/state-machine-cat "State-machine-cat node.js package"
[3]: https://github.com/sonntam/node-red-contrib-xstate-machine "Node-RED SMXstate package"