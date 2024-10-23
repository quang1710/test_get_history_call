package com.example.test_get_history_call

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.os.Bundle
import android.provider.CallLog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.test_get_history_call" // Tùy chỉnh theo ý bạn
    private val REQUEST_READ_CALL_LOG = 1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCallLogs" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CALL_LOG) != PackageManager.PERMISSION_GRANTED) {
                        // Yêu cầu quyền
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_CALL_LOG), REQUEST_READ_CALL_LOG)
                        result.error("PERMISSION_DENIED", "READ_CALL_LOG permission denied", null)
                    } else {
                        // Quyền đã được cấp, lấy dữ liệu
                        val callLogs = getCallLogs()
                        result.success(callLogs)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getCallLogs(): ArrayList<Map<String, String>> {
        val callLogs = ArrayList<Map<String, String>>()
        val cursor: Cursor? = contentResolver.query(CallLog.Calls.CONTENT_URI, null, null, null, "${CallLog.Calls.DATE} DESC")
        cursor?.use {
            val numberIndex = it.getColumnIndex(CallLog.Calls.NUMBER)
            val typeIndex = it.getColumnIndex(CallLog.Calls.TYPE)
            val dateIndex = it.getColumnIndex(CallLog.Calls.DATE)
            val durationIndex = it.getColumnIndex(CallLog.Calls.DURATION)

            while (it.moveToNext()) {
                val number = it.getString(numberIndex)
                val type = it.getString(typeIndex)
                val date = it.getString(dateIndex)
                val duration = it.getString(durationIndex)

                val callType = when (type.toInt()) {
                    CallLog.Calls.OUTGOING_TYPE -> "Cuộc gọi đi"
                    CallLog.Calls.INCOMING_TYPE -> "Cuộc gọi đến"
                    CallLog.Calls.MISSED_TYPE -> "Cuộc gọi nhỡ"
                    else -> "Loại khác"
                }

                val callLog = mapOf(
                    "number" to number,
                    "type" to callType,
                    "date" to date,
                    "duration" to duration
                )
                callLogs.add(callLog)
            }
        }
        return callLogs
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        // Có thể xử lý kết quả yêu cầu quyền tại đây nếu cần
    }
}