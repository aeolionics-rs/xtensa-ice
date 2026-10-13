use std::collections::BTreeMap;

/// Change N to vary the value size.
pub const N: usize = 184;

pub type Map = BTreeMap<u8, [u8; N]>;

pub fn insert(map: &mut Map, key: u8, value: [u8; N]) {
    map.insert(key, value);
}

pub fn remove(map: &mut Map, key: u8) -> Option<[u8; N]> {
    map.remove(&key)
}
