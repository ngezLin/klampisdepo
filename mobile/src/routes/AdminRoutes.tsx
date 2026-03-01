import { createDrawerNavigator } from "@react-navigation/drawer";
import { TouchableOpacity, Text } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useAuth } from "../context/AuthContext";

import DashboardPage from "../pages/dashboard/AdminDashboardPage";
import ItemsStack from "./ItemsStack";
import HistoryPage from "../pages/history/HistoryPage";
import TransactionPage from "../pages/transactions/TransactionPage";
import PrinterSettingsPage from "../pages/PrinterSettingsPage";

import LogoutScreen from "../components/LogoutScreen";

const Drawer = createDrawerNavigator();

export default function AdminRoutes() {
  const { logout } = useAuth();

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
        name="Dashboard"
        component={DashboardPage}
        options={{
          drawerIcon: ({ color, size }) => (
            <Ionicons name="home-outline" size={size} color={color} />
          ),
        }}
      />
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
        name="Items"
        component={ItemsStack}
        options={{
          headerShown: false,
          drawerIcon: ({ color, size }) => (
            <Ionicons name="cube-outline" size={size} color={color} />
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
