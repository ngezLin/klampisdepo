import AppRoutes from "./routes/AppRoutes";
import { Toaster } from "react-hot-toast";
import { BluetoothPrinterProvider } from "./context/BluetoothPrinterContext";

function App() {
  return (
    <BluetoothPrinterProvider>
      <AppRoutes />
      <Toaster position="top-right" />
    </BluetoothPrinterProvider>
  );
}

export default App;
