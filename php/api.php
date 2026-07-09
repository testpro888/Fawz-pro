<?php

use App\Http\Controllers\API\CheckMembershipController;
use App\Http\Controllers\API\ConfirmAgentController;
use App\Http\Controllers\API\MembershipCheckController;
use App\Http\Controllers\V1\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/ping', function () {
    return response()->json([
        'headers' => [
            'reason' => 'TST_PING_OK',
            'code' => 200,
        ],
        'status' => 'OK',
        'time' => now(),
    ], 200);
});

Route::any('/confirm-agent', [ConfirmAgentController::class, 'confirm'])->name('confirm.agent');

Route::middleware('throttle:30,1')->post('/fawzpro/check-membership', [CheckMembershipController::class, 'check'])->name('api.fawzpro.check-membership');

Route::middleware('throttle:60,1')->post('/fawzpro/check-tag', [CheckMembershipController::class, 'checkTag'])->name('api.fawzpro.check-tag');

Route::middleware('throttle:60,1')->post('/membership/check', [MembershipCheckController::class, 'check'])->name('api.membership.check');

Route::post('/midtrans/notification', [OrderController::class, 'notification'])->name('api.midtrans.notif');
