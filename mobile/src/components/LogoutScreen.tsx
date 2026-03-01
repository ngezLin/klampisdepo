import { useEffect } from "react";
import { View } from "react-native";
import { useAuth } from "../context/AuthContext";

export default function LogoutScreen() {
  const { logout } = useAuth();

  useEffect(() => {
    logout();
  }, []);

  return <View />;
}
