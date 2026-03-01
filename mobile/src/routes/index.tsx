import { ActivityIndicator, View } from "react-native";
import { useAuth } from "../context/AuthContext";
import AuthRoutes from "./AuthRoutes";
import AdminRoutes from "./AdminRoutes";
import CashierRoutes from "./CashierRoutes";

export default function Routes() {
  const { token, loading, role } = useAuth();

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: "center" }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (!token) return <AuthRoutes />;

  if (role === "admin" || role === "owner") return <AdminRoutes />;

  if (role === "cashier") return <CashierRoutes />;

  return null;
}
