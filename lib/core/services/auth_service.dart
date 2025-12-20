import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> validateSerialNumber(String serialNumber) async {
    try {
      final serial = int.tryParse(serialNumber);
      if (serial == null) return null;

      final response = await supabase
          .from('sensor_devices')
          .select('id, serial_number, is_assigned, created_at')
          .eq('serial_number', serial)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Serial validation error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserDevices(String userId) async {
    try {
      final response = await supabase
          .from('sensor_devices')
          .select('*')
          .eq('assigned_to', userId)
          .order('assigned_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Get user devices error: $e');
      return [];
    }
  }

  Future<bool> unassignDevice(String deviceId) async {
    try {
      await supabase
          .from('sensor_devices')
          .update({
        'is_assigned': false,
        'assigned_to': null,
        'assigned_at': null,
      })
          .eq('id', deviceId);

      return true;
    } catch (e) {
      print('Unassign device error: $e');
      return false;
    }
  }

  Future<bool> isSerialAlreadyUsed(String serialNumber) async {
    try {
      final serial = int.tryParse(serialNumber);
      if (serial == null) return true;

      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('serial_number', serial)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return true;
    }
  }
}