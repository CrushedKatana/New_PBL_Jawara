import { check, sleep } from "k6";
import http from "k6/http";

const BASE_URL = __ENV.PMPL_BASE_URL || "https://staging.example.com";

export const options = {
  stages: [
    { duration: "2m", target: 100 }, // load
    { duration: "3m", target: 500 }, // stress
    { duration: "2m", target: 150 }, // ramp down to soak level
    { duration: "30m", target: 150 }, // soak
  ],
  thresholds: {
    http_req_duration: ["p(95)<5000"],
    http_req_failed: ["rate<0.01"],
  },
};

export default function () {
  const res = http.get(`${BASE_URL}/health`);
  check(res, {
    "status is 200": (r) => r.status === 200,
  });

  const loginRes = http.post(`${BASE_URL}/api/v1/login`, JSON.stringify({
    email: "qa+valid@example.com",
    password: "Password123!",
  }), {
    headers: { "Content-Type": "application/json" },
  });

  check(loginRes, {
    "login < 2000ms": (r) => r.timings.duration < 2000,
    "login status ok": (r) => r.status === 200,
  });

  sleep(1);
}
