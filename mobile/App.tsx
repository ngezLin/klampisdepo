import "react-native-gesture-handler";

import { NavigationContainer } from "@react-navigation/native";
import { AuthProvider } from "./src/context/AuthContext";
import { PrinterProvider } from "./src/context/PrinterContext";
import Routes from "./src/routes";

export default function App() {
  return (
    <AuthProvider>
      <PrinterProvider>
        <NavigationContainer>
          <Routes />
        </NavigationContainer>
      </PrinterProvider>
    </AuthProvider>
  );
}
