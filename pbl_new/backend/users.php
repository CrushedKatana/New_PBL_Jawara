<?php
require_once __DIR__ . '/config.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(204);
  exit;
}

$method = $_SERVER['REQUEST_METHOD'];

function json_response($data, $code = 200) {
  http_response_code($code);
  echo json_encode($data);
  exit;
}

try {
  $pdo = get_db();

  switch ($method) {
    case 'GET':
      // /users?role=warga&rt=01&rw=05
      $role = $_GET['role'] ?? null;
      $rt = $_GET['rt'] ?? null;
      $rw = $_GET['rw'] ?? null;
      $id = $_GET['id'] ?? null;

      if ($id) {
        $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
        $stmt->execute([$id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        return json_response(['data' => $user]);
      }

      $sql = 'SELECT * FROM users WHERE 1=1';
      $params = [];
      if ($role) { $sql .= ' AND user_type = ?'; $params[] = $role; }
      if ($rt) { $sql .= ' AND rt = ?'; $params[] = $rt; }
      if ($rw) { $sql .= ' AND rw = ?'; $params[] = $rw; }
      $stmt = $pdo->prepare($sql);
      $stmt->execute($params);
      $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
      return json_response(['data' => $rows]);

    case 'POST':
      // create user
      $body = json_decode(file_get_contents('php://input'), true) ?? [];
      $id = $body['id'] ?? uniqid('user');
      $name = $body['name'] ?? '';
      $email = $body['email'] ?? '';
      $password = $body['password'] ?? '';
      $phone = $body['phone'] ?? null;
      $address = $body['address'] ?? null;
      $rt = $body['rt'] ?? null;
      $rw = $body['rw'] ?? null;
      $user_type = $body['user_type'] ?? 'warga';
      $verification_status = $body['verification_status'] ?? 'pending';

      if (!$name || !$email || !$password) {
        return json_response(['error' => 'Missing required fields'], 400);
      }

      $stmt = $pdo->prepare('INSERT INTO users (id,name,email,password,phone,address,rt,rw,user_type,verification_status,joined_date) VALUES (?,?,?,?,?,?,?,?,?,?,CURDATE())');
      $stmt->execute([$id,$name,$email,password_hash($password, PASSWORD_BCRYPT),$phone,$address,$rt,$rw,$user_type,$verification_status]);
      return json_response(['id' => $id], 201);

    case 'PUT':
      // update user
      parse_str($_SERVER['QUERY_STRING'] ?? '', $qs);
      $id = $qs['id'] ?? null;
      if (!$id) return json_response(['error' => 'Missing id'], 400);
      $body = json_decode(file_get_contents('php://input'), true) ?? [];

      $fields = ['name','email','phone','address','rt','rw','user_type','verification_status','is_active'];
      $set = [];
      $params = [];
      foreach ($fields as $f) {
        if (array_key_exists($f, $body)) { $set[] = "$f = ?"; $params[] = $body[$f]; }
      }
      if (isset($body['password'])) { $set[] = 'password = ?'; $params[] = password_hash($body['password'], PASSWORD_BCRYPT); }
      if (!$set) return json_response(['error' => 'No fields to update'], 400);
      $params[] = $id;
      $sql = 'UPDATE users SET ' . implode(',', $set) . ' WHERE id = ?';
      $stmt = $pdo->prepare($sql);
      $stmt->execute($params);
      return json_response(['updated' => true]);

    case 'DELETE':
      parse_str($_SERVER['QUERY_STRING'] ?? '', $qs);
      $id = $qs['id'] ?? null;
      if (!$id) return json_response(['error' => 'Missing id'], 400);
      $stmt = $pdo->prepare('DELETE FROM users WHERE id = ?');
      $stmt->execute([$id]);
      return json_response(['deleted' => true]);

    default:
      return json_response(['error' => 'Method Not Allowed'], 405);
  }
} catch (Throwable $e) {
  return json_response(['error' => $e->getMessage()], 500);
}
