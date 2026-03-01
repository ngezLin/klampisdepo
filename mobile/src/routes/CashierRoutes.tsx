import { createDrawerNavigator } from "@react-navigation/drawer";
import { TouchableOpacity, Text } from "react-native";
import { Ionicons } from "@expo/vector-icons";

import TransactionPage from "../pages/transactions/TransactionPage";
import HistoryPage from "../pages/history/HistoryPage";
import PrinterSettingsPage from "../pages/PrinterSettingsPage";

import LogoutScreen from "../components/LogoutScreen";

const Drawer = createDrawerNavigator();

export default function CashierRoutes() {
  return (
    <Drawer.Navigator
      screenOptions={({ navigation }) => ({
        headerLeft: () => (
          <TouchableOpacity
            onPress={() => navigation.openDrawer()}
            style={{ marginLeft: 16 }}
          >
            <Ionicons name="menu" size={24} />
          </TouchableOpacity>
        ),
      })}
    >
      <Drawer.Screen
        name="Transaction"
        component={TransactionPage}
        options={{
          drawerIcon: ({ color, size }) => (
            <Ionicons name="receipt-outline" size={size} color={color} />
          ),
        }}
      />

      <Drawer.Screen
        name="History"
        component={HistoryPage}
        options={{
          drawerIcon: ({ color, size }) => (
            <Ionicons name="time-outline" size={size} color={color} />
          ),
        }}
      />

      <Drawer.Screen
        name="Printer"
        component={PrinterSettingsPage}
        options={{
          drawerIcon: ({ color, size }) => (
            <Ionicons name="print-outline" size={size} color={color} />
          ),
        }}
      />

      <Drawer.Screen
        name="Logout"
        component={LogoutScreen}
        options={{
          drawerLabel: () => (
            <Text style={{ color: "red", marginLeft: 16 }}>Logout</Text>
          ),
          drawerIcon: () => (
            <Ionicons name="log-out-outline" size={20} color="red" />
          ),
        }}
      />
    </Drawer.Navigator>
  );
}
