import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

/// Returns a `hashCode` for [props].
int mapPropsToHashCode(Iterable<Object?>? props) {
  return _finish(props == null ? 0 : props.fold(0, _combine));
}

/// Determines whether [a] and [b] are equal.
// This method is optimized for comparing properties
// from primitive types like int, double, String, bool.
bool equals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final unitA = a[i];
    final unitB = b[i];
    if (_isEquatable(unitA) && _isEquatable(unitB)) {
      return unitA == unitB;
    } else if (unitA is Set && unitB is Set) {
      return _setEquals(unitA, unitB);
    } else if (unitA is Iterable && unitB is Iterable) {
      return _iterableEquals(unitA, unitB);
    } else if (unitA is Map && unitB is Map) {
      return _mapEquals(unitA, unitB);
    } else if (unitA?.runtimeType != unitB?.runtimeType) {
      return false;
    } else if (unitA != unitB) {
      return false;
    }
  }
  return true;
}

bool _objectsEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (_isEquatable(a) && _isEquatable(b)) {
    return a == b;
  } else if (a is Set && b is Set) {
    return _setEquals(a, b);
  } else if (a is List && b is List) {
    return _iterableEquals(a, b);
  } else if (a is Map && b is Map) {
    return _mapEquals(a, b);
  } else if (a?.runtimeType != b?.runtimeType) {
    return false;
  } else if (a != b) {
    return false;
  }
  return true;
}

bool _isEquatable(Object? object) {
  return object is Equatable || object is EquatableMixin;
}

bool _setEquals(Set<Object?> a, Set<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  if (a.any((e) => !b.contains(e))) return false;
  return true;
}

bool _iterableEquals(Iterable<Object?> a, Iterable<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_objectsEquals(a.elementAt(i), b.elementAt(i))) return false;
  }
  return true;
}

bool _mapEquals(Map<Object?, Object?> a, Map<Object?, Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!_objectsEquals(a[key], b[key])) return false;
  }
  return true;
}

/// Jenkins Hash Functions
/// https://en.wikipedia.org/wiki/Jenkins_hash_function
int _combine(int hash, Object? object) {
  if (object is Map) {
    object.keys
        .sorted((Object? a, Object? b) => a.hashCode - b.hashCode)
        .forEach((Object? key) {
      hash = hash ^ _combine(hash, [key, (object! as Map)[key]]);
    });
    return hash;
  }
  if (object is Set) {
    object = object.sorted((Object? a, Object? b) => a.hashCode - b.hashCode);
  }
  if (object is Iterable) {
    for (final value in object) {
      hash = hash ^ _combine(hash, value);
    }
    return hash ^ object.length;
  }

  hash = 0x1fffffff & (hash + object.hashCode);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

int _finish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Returns a string for [props].
String mapPropsToString(Type runtimeType, List<Object?> props) {
  return '$runtimeType(${props.map((prop) => prop.toString()).join(', ')})';
}
