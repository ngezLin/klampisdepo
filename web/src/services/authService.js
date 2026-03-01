import api from "./api";

export async function login(username, password) {
  const res = await api.post("/login", { username, password });
  const token = res.data.token;

  // Save token
  localStorage.setItem("token", token);

  // Decode JWT and save role
  let user = { username, role: res.data.Role || res.data.role };
  try {
    const payload = JSON.parse(atob(token.split(".")[1]));
    user.role = payload.role;
    localStorage.setItem("role", payload.role);
  } catch (decodeError) {
    console.error("Failed to decode token:", decodeError);
  }

  return { user, token };
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
