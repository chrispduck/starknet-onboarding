%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.math import (assert_le)

@storage_var
func dust(address: felt) -> (amount: felt):
end

# TODO
# Create two storages `star` and `slot`
# `star` will map an `address` and a `slot` to a `star`
# `slot` will map an `address` to the next available `slot` this `address` can use
@storage_var
func star(address: felt, slot: felt) -> (star: felt):
end

@storage_var
func slot(address: felt) -> (slot: felt):
end

# TODO
# Create an event `a_star_is_born`
# It will log:
# - the `account` that issued the transaction 
# - the `slot` where this `star` has been registered
# - the size of the given `star`
# https://starknet.io/documentation/events/
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

# This external allow an user to create a `star` by destroying an amount of `dust`
# The resulting star will have a `size` equal to the amount of `dust` used
@external
func light_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        dust_amount: felt):
    # TODO
    # Get the caller address
    let (address) = get_caller_address()

    # Get the amount on dust owned by the caller
    let (current_dust) =  dust.read(address)

    # Make sure this amount is at least equal to `dust_amount`
    assert_le(dust_amount, current_dust)

    # Get the caller next available `slot`
    let (next_slot) = slot.read(address)

    # Update the amount of dust owned by the caller
    dust.write(address, current_dust-dust_amount)

    # Register the newly created star
    star.write(address, next_slot, dust_amount)

    # Increment the caller next available slot
    slot.write(address, next_slot + 1)

    # Emit an `a_star_is_born` even with appropiate valued
    a_star_is_born.emit(address,next_slot,dust_amount)
    return ()
end


@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = dust.read(address)
    return (res)
end

#TODO
# Write two views, for the `star` and `slot` storages
# 1.
@view
func view_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt, slot: felt) -> (
        star: felt):
    let (res) = star.read(address, slot)
    return (res)
end

@view
func view_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        slot: felt):
    let (res) = slot.read(address)
    return (res)
end