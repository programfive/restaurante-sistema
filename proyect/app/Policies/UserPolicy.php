<?php

namespace App\Policies;

use App\Models\User;
use Illuminate\Auth\Access\Response;

class UserPolicy
{
    public function viewAny(User $user): bool
    {
         //  return $user->can('ver usuarios');
         return true;
    }

    public function view(User $user, User $model): bool
    {
        return $user->can('ver usuarios');
        // return true;
    }

    public function create(User $user): bool
    {
        return $user->can('crear usuarios');
        // return true;
    }

    public function update(User $user, User $model): bool
    {
        return $user->can('actualizar usuarios');
        // return true;
    }

    public function delete(User $user, User $model): bool
    {
        return $user->can('eliminar usuarios');
        // return true;
    }
}
