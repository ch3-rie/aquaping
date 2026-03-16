<?php
header('Content-Type: application/json');

if (isset($_POST['device_id'], $_POST['water_level'], $_POST['severity'])) {
    $device_id = $_POST['device_id'];
    $level = intval($_POST['water_level']);
    $severity = $_POST['severity'];

    $conn = new mysqli("localhost", "root", "", "aquaping");
    if ($conn->connect_error) {
        echo json_encode(["success" => false, "message" => "DB connection failed: " . $conn->connect_error]);
        exit;
    }

    $stmt = $conn->prepare("INSERT INTO water_levels (device_id, water_level, severity, created_at) VALUES (?, ?, ?, NOW())");
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
        exit;
    }

    $stmt->bind_param("sis", $device_id, $level, $severity);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "level" => $level, "severity" => $severity]);
    } else {
        echo json_encode(["success" => false, "message" => "Insert failed: " . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Missing parameters"]);
}
?>
