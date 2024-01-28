_:
let
  # TODO: mode it into application layer
  fromStr = sizeStr:
    let
      matchResult = builtins.match "([0-9]+)GiB" sizeStr;
    in
    assert matchResult != null; builtins.head matchResult;

  mkTotalStorageSize = node:
    let
      storageSizes = map (disk: disk.sizeGib) node.resources.storage.disks;
    in
    builtins.foldl' (acc: size: acc + (fromStr size)) 0 storageSizes;

  mkDefaults = node:
    let
      defaultbackupKernels = 2;
    in
    node
    // {
      useUEFI = node.resources.storage.useUEFI or false;
      numberOfKernels =
        node.resources.storage.numberOfKernels or defaultbackupKernels;
    };

  mkBootSize = node:
    let
      node' = mkDefaults node;
      baseSize =
        if node'.resources.storage.useUEFI
        then 300
        else 100;
      perKernelSize = 25;
    in
    baseSize + (node'.resources.storage.numberOfKernels * perKernelSize);

  mkSwapSize = node:
    let
      node' = mkDefaults node;
      inherit (node'.resources) memory;
      storage = mkTotalStorageSize node';
      halfMemory = memory / 2;
      maxSwap = 4096;
      baseSwap =
        if memory < 2048
        then memory
        else if memory <= 8192
        then halfMemory
        else maxSwap;
      additionalStorageSwap = storage / 10;
    in
    baseSwap + additionalStorageSwap - (mkBootSize node');

  mkRootSize = node:
    let
      node' = mkDefaults node;
      storage = mkTotalStorageSize node';
      bootSize = mkBootSize node';
      swapSize = mkSwapSize node';
    in
    storage - bootSize - swapSize;

  mkPartitionLayoutForNode = node:
    let
      node' = mkDefaults node;
      bootSize = mkBootSize node';
      swapSize = mkSwapSize node';
      rootSize = mkRootSize node';

      bootEnd = bootSize;
      swapEnd = bootSize + swapSize;
      rootEnd = bootSize + swapSize + rootSize;
    in
    {
      boot = {
        start = 0;
        end = bootEnd;
      };
      swap = {
        start = bootEnd;
        end = swapEnd;
      };
      root = {
        start = swapEnd;
        end = rootEnd;
      };
    };
in
{
  configure = { nodes }:
    let
      mkTopology = nodes: {
        nodes =
          builtins.mapAttrs
            (_nodeId: node: {
              storage = {
                partitions = mkPartitionLayoutForNode (mkDefaults node);
                inherit (node.resources.storage) disks;
              };
            })
            nodes;
      };
    in
    {
      # topology = mkTopology nodes;
      topology = { };
      mkLayout = nodeId: topology.nodes.${nodeId}.storage.partitions;
      mkdisks = nodeId: topology.nodes.${nodeId}.storage.disks;
    };
}
