/// Version constants for the wire protocol implemented by this package.
///
/// The generated protobuf model is also called `ProtocolVersion`, so this
/// constants holder deliberately uses a distinct name.
abstract final class RemoteInputProtocolVersion {
  static const major = 1;
  static const minor = 3;
  static const display = '$major.$minor';
}
