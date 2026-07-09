<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MembershipCheckController extends Controller
{
    /**
     * Check membership status by email.
     * Returns email and membership status (member or non-member).
     */
    public function check(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
        ]);

        $user = User::query()
            ->where('email', $request->email)
            ->first(['email', 'is_member', 'ends_at']);

        if (! $user) {
            return response()->json([
                'success' => true,
                'data' => [
                    'email' => $request->email,
                    'is_member' => false,
                    'membership_status' => 'non-member',
                ],
            ], 200);
        }

        $isMember = $user->is_member && ($user->ends_at === null || $user->ends_at->isFuture());

        return response()->json([
            'success' => true,
            'data' => [
                'email' => $user->email,
                'is_member' => $isMember,
                'membership_status' => $isMember ? 'member' : 'non-member',
            ],
        ], 200);
    }
}
