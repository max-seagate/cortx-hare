let Prelude = $path/Prelude.dhall

let T = $path/types.dhall
let P = T.Protocol
let DiskRef = T.DiskRef

let M0dProcess =
      { runs_confd : Optional Bool
      , io_disks : { meta_data : Optional Text, data : List Text }
      }

let NodeInfo =
      { hostname : Text
      , data_iface : Text
      , data_iface_type : Optional T.Protocol
      , m0_servers : Optional  (List M0dProcess)
      , s3_instances : Natural
      }

let PoolInfo =
      { name : Text
      , disk_refs : Optional (List T.DiskRef)
      , data_units : Natural
      , parity_units : Natural
      , spare_units : Optional Natural
      , type : T.PoolType
      }

let ProfileInfo =
      { name : Text
      , pools : List Text
      }

let ClusterInfo =
      { node_info: List NodeInfo
      , pool_info: List PoolInfo
      , profile_info: List ProfileInfo
      , fdmi_filter_info: Optional (List T.FdmiFilterDesc)
      }

let toNodeDesc
    : NodeInfo -> T.NodeDesc
    =     \(n : NodeInfo)
      ->  { hostname = n.hostname
          , data_iface = n.data_iface
          , data_iface_type = n.data_iface_type
          , m0_clients = { other = 3, s3 = n.s3_instances }
          , m0_servers = n.m0_servers
          }

let toPoolDesc
    : PoolInfo -> T.PoolDesc
    =     \(p : PoolInfo)
      ->  { name = p.name
          , type = Some p.type
          , disk_refs = p.disk_refs
          , data_units = p.data_units
          , parity_units = p.parity_units
          , spare_units = p.spare_units
          , allowed_failures =
                    None
                      { ctrl : Natural
                      , disk : Natural
                      , encl : Natural
                      , rack : Natural
                      , site : Natural
                      }
          }

let genCdf
    : ClusterInfo -> T.ClusterDesc
    =     \(cluster_info : ClusterInfo)
      ->  { nodes = Prelude.List.map NodeInfo T.NodeDesc toNodeDesc cluster_info.node_info
          , pools = Prelude.List.map PoolInfo T.PoolDesc toPoolDesc cluster_info.pool_info
          , profiles = Some cluster_info.profile_info
          , fdmi_filters = cluster_info.fdmi_filter_info
          }

in  genCdf
$params
