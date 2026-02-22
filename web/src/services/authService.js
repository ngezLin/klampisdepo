import api from "./api";

export async function login(username, password) {
  try {
    const res = await api.post("/login", { username, password });
    const token = res.data.token;

    // Save token
    localStorage.setItem("token", token);

    // Decode JWT and save role
    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      console.log("Decoded token payload:", payload); // Debug log
      localStorage.setItem("role", payload.role);
      console.log("Saved role:", payload.role); // Debug log
    } catch (decodeError) {
      console.error("Failed to decode token:", decodeError);
    }

    return { success: true, token };
  } catch (err) {
    const errorMsg = err.response?.data?.error || "Login gagal";
    return { success: false, error: errorMsg };
  }
}

export function logout() {
  localStorage.removeItem("token");
  localStorage.removeItem("role");
}

export function getToken() {
  return localStorage.getItem("token");
}

export function getUserRole() {
  return localStorage.getItem("role");
}

export function isAdmin() {
  return getUserRole() === "admin";
}
