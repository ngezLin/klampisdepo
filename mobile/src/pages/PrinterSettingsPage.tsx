import { useEffect } from "react";
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
} from "react-native";
import { usePrinter } from "../context/PrinterContext";

export default function PrinterSettingsPage() {
  const {
    devices,
    connectedDevice,
    loading,
    scanDevices,
    connectPrinter,
    disconnectPrinter,
  } = usePrinter();

  useEffect(() => {
    scanDevices();
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Printer Settings</Text>

      <View style={styles.statusBox}>
        <Text style={styles.subtitle}>Current Status:</Text>
        {connectedDevice ? (
          <View>
            <Text style={styles.connectedText}>
              Connected to: {connectedDevice.name}
            </Text>
            <TouchableOpacity
              onPress={disconnectPrinter}
              style={styles.btnDanger}
            >
              <Text style={styles.btnText}>Disconnect</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <Text style={styles.disconnectedText}>Not Connected</Text>
        )}
      </View>

      <View style={styles.scanRow}>
        <Text style={styles.subtitle}>Available Devices:</Text>
        <TouchableOpacity
          onPress={scanDevices}
          style={styles.btnPrimary}
          disabled={loading}
        >
          <Text style={styles.btnText}>{loading ? "Scanning..." : "Scan"}</Text>
        </TouchableOpacity>
      </View>

      {loading && devices.length === 0 ? (
        <ActivityIndicator size="large" style={{ marginTop: 20 }} />
      ) : (
        <FlatList
          data={devices}
          keyExtractor={(item, index) => item.address || index.toString()}
          ListEmptyComponent={
            <Text style={styles.empty}>
              No Bluetooth devices found. Ensure Bluetooth is on and location
              permissions are granted.
            </Text>
          }
          renderItem={({ item }) => (
            <View style={styles.deviceCard}>
              <View>
                <Text style={styles.deviceName}>
                  {item.name || "Unknown Device"}
                </Text>
                <Text style={styles.deviceAddress}>{item.address}</Text>
              </View>
              <TouchableOpacity
                style={[
                  styles.btnConnect,
                  connectedDevice?.address === item.address &&
                    styles.btnConnected,
                ]}
                onPress={() => connectPrinter(item)}
                disabled={loading || connectedDevice?.address === item.address}
              >
                <Text style={styles.btnText}>
                  {connectedDevice?.address === item.address
                    ? "Connected"
                    : "Connect"}
                </Text>
              </TouchableOpacity>
            </View>
          )}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: "#f1f5f9",
  },
  title: {
    fontSize: 22,
    fontWeight: "bold",
    marginBottom: 20,
  },
  subtitle: {
    fontSize: 16,
    fontWeight: "bold",
    marginBottom: 8,
  },
  statusBox: {
    backgroundColor: "#fff",
    padding: 16,
    borderRadius: 8,
    marginBottom: 20,
    elevation: 2,
  },
  connectedText: {
    color: "#059669",
    fontWeight: "bold",
    marginBottom: 10,
  },
  disconnectedText: {
    color: "#dc2626",
    fontWeight: "bold",
    fontStyle: "italic",
  },
  scanRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
  },
  deviceCard: {
    backgroundColor: "#fff",
    padding: 12,
    borderRadius: 8,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 10,
    elevation: 1,
  },
  deviceName: {
    fontWeight: "bold",
    fontSize: 16,
  },
  deviceAddress: {
    color: "#64748b",
    fontSize: 12,
  },
  btnPrimary: {
    backgroundColor: "#2563eb",
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
  },
  btnConnect: {
    backgroundColor: "#059669",
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
  },
  btnConnected: {
    backgroundColor: "#9ca3af",
  },
  btnDanger: {
    backgroundColor: "#dc2626",
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
    alignSelf: "flex-start",
  },
  btnText: {
    color: "#fff",
    fontWeight: "bold",
  },
  empty: {
    color: "#64748b",
    textAlign: "center",
    marginTop: 20,
    fontStyle: "italic",
  },
});
