{lib, ...}: {
  findCurrentNode = nodes: (lib.findFirst (node: node.current) null (lib.attrValues nodes));
  currentNodeHostname = nodes: (lib.findFirst (nodeName: nodes.${nodeName}.current) null (lib.attrNames nodes));
}
