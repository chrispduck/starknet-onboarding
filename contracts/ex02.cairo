%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.math import (assert_le)

# We want to store more info than just the `star` size.
# We are going to give them a name and a size

# Create a `Star` stuct
# It must have two members:
# - name
# - size
# Both members are of type `felt`
# https://www.cairo-lang.org/docs/reference/syntax.html#structs

struct Star:
    member name: felt
    member size: felt
end

@storage_var
func dust(address: felt) -> (amount: felt):
end

# Update the `star` storage to store `Star` instead of `felt`
@storage_var
func star(address: felt, slot: felt) -> (star: Star):
end

@storage_var
func slot(address: felt) -> (slot: felt):
end

@event
func a_star_is_born(account: felt, slot: felt, size: felt):
end

@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt):
    let (address) = get_caller_address()

    let (res) = dust.read(address)
    dust.write(address, res + amount)

    return ()
end

# Update the `light_star` external so it take a `Star` struct instead of the amount of dust
# Caller `dust` storage must be deducted form a amount equal to the star size
@external
func light_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _star: Star):
    # Get the caller address
    let (address) = get_caller_address()

    # Get the amount on dust owned by the caller
    let (current_dust) =  dust.read(address)

    # Make sure this amount is at least equal to `dust_amount`
    assert_le(_star.size, current_dust)

    # Get the caller next available `slot`
    let (next_slot) = slot.read(address)

    # Update the amount of dust owned by the caller
    dust.write(address, current_dust-_star.size)

    # Register the newly created star
    star.write(address, next_slot, _star)

    # # Increment the caller next available slot
    slot.write(address, next_slot + 1)

    # # Emit an `a_star_is_born` even with appropiate valued
    a_star_is_born.emit(address,next_slot,_star.size)
    return ()
end

@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = dust.read(address)
    return (res)
end

# TODO
# Create a view for `star`
# It must return an instance of `Star` instead of a `felt`
@view
func view_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt, slot: felt) -> (
        star: Star):
    let (res) = star.read(address, slot)
    return (res)
end
@view
func view_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = slot.read(address)
    return (res)
end