import React, { createContext, useContext, useEffect, useState } from "react";
import { BLEPrinter } from "react-native-thermal-receipt-printer-image-qr";
import AsyncStorage from "@react-native-async-storage/async-storage";

interface PrinterDevice {
  name: string;
  address: string;
}

interface PrinterContextType {
  devices: PrinterDevice[];
  connectedDevice: PrinterDevice | null;
  loading: boolean;
  scanDevices: () => Promise<void>;
  connectPrinter: (device: PrinterDevice) => Promise<void>;
  disconnectPrinter: () => Promise<void>;
}

const PrinterContext = createContext<PrinterContextType>(
  {} as PrinterContextType,
);

export const PrinterProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [devices, setDevices] = useState<PrinterDevice[]>([]);
  const [connectedDevice, setConnectedDevice] = useState<PrinterDevice | null>(
    null,
  );
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Attempt to reconnect to previously saved printer on startup
    const initPrinter = async () => {
      try {
        const savedAddress = await AsyncStorage.getItem("printer_address");
        const savedName = await AsyncStorage.getItem("printer_name");

        if (savedAddress && savedName) {
          await BLEPrinter.connectPrinter(savedAddress);
          setConnectedDevice({ name: savedName, address: savedAddress });
        }
      } catch (err) {
        console.log("Auto-connect printer failed:", err);
      }
    };

    initPrinter();
  }, []);

  const scanDevices = async () => {
    try {
      setLoading(true);
      await BLEPrinter.init();
      const res = await BLEPrinter.getDeviceList();
      // getDeviceList returns an array of objects for BLEPrinter in this library typically,
      // but let's map it safely if it returns strings. (BLEPrinter interface is IBLEPrinter)
      const scannedDevices: PrinterDevice[] = res
        .map((d: any) => {
          if (typeof d === "string") {
            try {
              return JSON.parse(d);
            } catch {
              return null;
            }
          }
          return { name: d.device_name, address: d.inner_mac_address };
        })
        .filter((d: any) => d !== null);

      setDevices(scannedDevices);
    } catch (err) {
      console.log("Error scanning bluetooth devices", err);
    } finally {
      setLoading(false);
    }
  };

  const connectPrinter = async (device: PrinterDevice) => {
    try {
      setLoading(true);
      await BLEPrinter.connectPrinter(device.address);
      setConnectedDevice(device);

      // Save for auto-reconnect
      await AsyncStorage.multiSet([
        ["printer_name", device.name || ""],
        ["printer_address", device.address || ""],
      ]);
    } catch (err) {
      console.log("Error connecting to printer", err);
      throw err;
    } finally {
      setLoading(false);
    }
  };

  const disconnectPrinter = async () => {
    try {
      if (connectedDevice) {
        setLoading(true);
        // BluetoothManager technically doesn't have an explicit manual disconnect in all forks,
        // but we can clear our state so we stop trying to print to it.
        setConnectedDevice(null);
        await AsyncStorage.multiRemove(["printer_name", "printer_address"]);
      }
    } catch (err) {
      console.log("Error disconnecting printer", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <PrinterContext.Provider
      value={{
        devices,
        connectedDevice,
        loading,
        scanDevices,
        connectPrinter,
        disconnectPrinter,
      }}
    >
      {children}
    </PrinterContext.Provider>
  );
};

export const usePrinter = () => useContext(PrinterContext);
