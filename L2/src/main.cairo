%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le
from starkware.starknet.common.messages import send_message_to_l1

const MESSAGE_WITHDRAW = 1
const FEE = 100000000000000

# mapping to store user's L1 address and balance
@storage_var
    func user_balance(user_l1_address: felt) -> (balance: felt):
end

# stores stake L1 contract's address
@storage_var
    func stake_l1_address() -> (address: felt):
end

# 
# Getters
# 

@view
func get_balance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(user_l1_address_: felt) -> (balance: felt):
    let (balance) = user_balance.read(user_l1_address_)
    return (balance)
end

@view 
func get_l1_address{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (l1_address: felt):
    let (l1_address) = stake_l1_address.read()
    return (l1_address)
end

# 
# L1 Handler
# 

@l1_handler
func deposit{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(from_address: felt, user_l1_address_: felt, amount_: felt):
    let (l1_address) = stake_l1_address.read()
    assert from_address = l1_address

    let (current_balance) = user_balance.read(user_l1_address_)
    let new_balance = current_balance + amount_
    user_balance.write(user_l1_address_, new_balance)

    return ()
end

# 
# Externals
# 

@external
func set_stake_l1_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    stake_l1_address_ : felt
):
    stake_l1_address.write(stake_l1_address_)

    return ()
end

@external
func withdraw{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(user_l1_address_: felt, amount_: felt):
    let (balance) = user_balance.read(user_l1_address_)

    # check requested amount is less than balance
    assert_le(amount_, balance)

    let remainder = balance - amount_

    # update balance
    user_balance.write(user_l1_address_, remainder)

    let (l1_address) = stake_l1_address.read()

    # prepare the withdrawal message
    let (message_payload: felt*) = alloc()
    assert message_payload[0] = MESSAGE_WITHDRAW
    assert message_payload[1] = user_l1_address_
    assert message_payload[2] = amount_

    # send Message to L1
    send_message_to_l1(to_address=l1_address, payload_size=3, payload=message_payload)

    return ()
end

@external
func take_fee{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(user_l1_address_: felt):
    let (balance) = user_balance.read(user_l1_address_)

    # check that fee is less than balance
    assert_le(FEE, balance)

    # get remainder after subtracting Fee
    let remainder = balance - FEE

    # update user balance
    user_balance.write(user_l1_address_, remainder)

    return ()
end