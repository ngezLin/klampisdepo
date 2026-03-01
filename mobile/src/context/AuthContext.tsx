import React, { createContext, useContext, useEffect, useState } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { login as loginService } from "../services/auth.service";

type UserRole = "admin" | "cashier" | "owner" | null;

interface AuthContextType {
  token: string | null;
  role: UserRole;
  loading: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({} as AuthContextType);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [token, setToken] = useState<string | null>(null);
  const [role, setRole] = useState<UserRole>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadAuth = async () => {
      const storedToken = await AsyncStorage.getItem("token");
      const storedRole = await AsyncStorage.getItem("role");

      if (storedToken) setToken(storedToken);
      if (storedRole) setRole(storedRole as UserRole);

      setLoading(false);
    };

    loadAuth();
  }, []);

  const login = async (username: string, password: string) => {
    const res = await loginService(username, password);

    const { token, role } = res.data;

    await AsyncStorage.multiSet([
      ["token", token],
      ["role", role],
    ]);

    setToken(token);
    setRole(role);
  };

  const logout = async () => {
    await AsyncStorage.multiRemove(["token", "role"]);
    setToken(null);
    setRole(null);
  };

  return (
    <AuthContext.Provider value={{ token, role, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
