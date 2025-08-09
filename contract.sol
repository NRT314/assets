// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// Standard ERC20 interfaces
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// OpenZeppelin-style base contracts
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address spender => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal virtual {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

contract ERC20Burnable is Context, ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_){}
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
}

contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _reentrancyGuardEnter();
        _;
        _reentrancyGuardLeave();
    }

    function _reentrancyGuardEnter() private {
        if (_status == _ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = _ENTERED;
    }

    function _reentrancyGuardLeave() private {
        _status = _NOT_ENTERED;
    }
}

contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    uint256 private _paused;
    error EnforcedPause();
    error ExpectedPause();

    constructor() {
        _paused = 0;
    }

    modifier whenNotPaused() {
        _checkNotPaused();
        _;
    }

    modifier whenPaused() {
        _checkPaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused != 0;
    }

    function _checkNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    function _checkPaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    function _pause() internal virtual whenNotPaused {
        _paused = block.timestamp;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = 0;
        emit Unpaused(_msgSender());
    }
}

// Custom errors for NewRussiaToken
error NotAdmin();
error TokenNotAllowed();
error LengthMismatch();
error RecipientNotAllowed();
error DonationTooSmall();
error AtLeastTwoRecipientsRequired();
error MaxShareExceeded();
error TokenTransferFailed();
error TokenTransferReturnFalse();
error TokenTransferFromFailed();
error TokenTransferFromReturnFalse();
error PresetAlreadyExists();
error RecipientsEmpty();
error PercentagesNot100();
error PresetNotFound();
error ZeroAddress();
error RecipientNotInWhitelist();
error ZeroRate();
error DecimalsTooHigh();
error TokenNotInWhitelist();
error CannotRecoverWhitelistedToken();
error MaxCommissionRateExceeded();
error NrtIsNonTransferable();
error DuplicateRecipientInList(address recipient);
error RecipientAlreadyInWhitelist();

contract NewRussiaToken is ERC20Burnable, Ownable, ReentrancyGuard, Pausable {
    IERC20 public usdt;
    mapping(address => bool) public whitelistToken;
    mapping(address => bool) public whitelistRecipient;
    mapping(address => bool) public admins;
    mapping(address => uint256) public tokenUsdtRatesIn1e18;
    mapping(address => uint256) public tokenDecimals;
    mapping(address => uint256) public totalDonatedByInUsdt;
    mapping(address => uint256) public totalReceivedInUsdt;
    uint256 public totalDonatedOverallInUsdt;
    address[] private whitelistedTokens;
    address[] private whitelistedRecipients;

    struct Preset {
        address[] recipients;
        uint256[] percentages;
    }
    mapping(string => Preset) private presets;

    event Donation(address indexed donor, address indexed token, address indexed recipient, uint256 amount);
    event RecipientAdded(address indexed recipient);
    event TokenWhitelisted(address indexed token);
    event TokenRemoved(address indexed token);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event PresetCreated(string indexed name);
    event StrictModeChanged(bool enabled);
    event MintModeChanged(bool strictMode);
    event TokenInfoUpdated(address indexed token, uint256 rateIn1e18, uint256 decimals);
    event PresetUpdated(string indexed name);
    event PresetRemoved(string indexed name);
    event CommissionRateChanged(uint256 newRate);
    event CommissionWalletChanged(address newWallet);
    event CommissionStatusChanged(bool enabled);

    bool public strictDonationMode = false;
    uint256 public minDonationAmount = 5000;
    uint256 private constant USDT_DECIMALS = 6;
    uint256 private constant NRT_DECIMALS = 18;
    address public commissionWallet;
    uint256 public commissionRate = 0;
    bool public commissionEnabled = false;

    constructor() ERC20Burnable("NewRussiaToken", "NRT") Ownable(msg.sender) {
        usdt = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        whitelistToken[address(usdt)] = true;
        whitelistedTokens.push(address(usdt));
        tokenUsdtRatesIn1e18[address(usdt)] = 1e18;
        tokenDecimals[address(usdt)] = USDT_DECIMALS;
        emit TokenInfoUpdated(address(usdt), tokenUsdtRatesIn1e18[address(usdt)], tokenDecimals[address(usdt)]);

        address usdcAddress = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        whitelistToken[usdcAddress] = true;
        whitelistedTokens.push(usdcAddress);
        tokenUsdtRatesIn1e18[usdcAddress] = 1e18;
        tokenDecimals[usdcAddress] = 6;
        emit TokenInfoUpdated(usdcAddress, tokenUsdtRatesIn1e18[usdcAddress], tokenDecimals[usdcAddress]);

        address daiAddress = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
        whitelistToken[daiAddress] = true;
        whitelistedTokens.push(daiAddress);
        tokenUsdtRatesIn1e18[daiAddress] = 1e18;
        tokenDecimals[daiAddress] = 18;
        emit TokenInfoUpdated(daiAddress, tokenUsdtRatesIn1e18[daiAddress], tokenDecimals[daiAddress]);

        whitelistRecipient[0xc0F467567570AADa929fFA115E65bB39066e3E42] = true;
        whitelistedRecipients.push(0xc0F467567570AADa929fFA115E65bB39066e3E42);
        admins[msg.sender] = true;
        commissionWallet = 0xc0F467567570AADa929fFA115E65bB39066e3E42;
    }

    modifier onlyAdmin() {
        if (!(admins[msg.sender] || msg.sender == owner())) {
            revert NotAdmin();
        }
        _;
    }

    function safeTransferCompatible(IERC20 token, address to, uint256 amount) internal {
        (bool success, bytes memory returndata) = address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, to, amount));
        if (!success) {
            revert TokenTransferFailed();
        }
        if (returndata.length > 0) {
            if (!abi.decode(returndata, (bool))) {
                revert TokenTransferReturnFalse();
            }
        }
    }

    function safeTransferFromCompatible(IERC20 token, address from, address to, uint256 amount) internal {
        (bool success, bytes memory returndata) = address(token).call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount));
        if (!success) {
            revert TokenTransferFromFailed();
        }
        if (returndata.length > 0) {
            if (!abi.decode(returndata, (bool))) {
                revert TokenTransferFromReturnFalse();
            }
        }
    }

    /**
     * @notice Calculates the USDT equivalent of a token amount, targeting 6 decimals for USDT.
     * @dev This version is mathematically simplified to perform all multiplications before division,
     * preventing precision loss with integer arithmetic. The formula is an optimized
     * version of: (amount * 10**(18-decs) * rate / 1e18) / 10**(18-6).
     */
    function _calculateUsdtEquivalent(address token, uint256 amount) internal view returns (uint256 usdtAmountIn6Decimals) {
        uint256 rate = tokenUsdtRatesIn1e18[token];
        uint256 decs = tokenDecimals[token];

        if (rate == 0) revert ZeroRate();
        if (decs > 77) revert DecimalsTooHigh();

        // The formula simplifies to (amount * rate) / 10^(decs + 12), which correctly
        // normalizes any token amount to a 6-decimal USDT value.
        return (amount * rate) / (10 ** (decs + 12));
    }

    function toNrt(uint256 usdtAmountIn6Decimals) internal pure returns (uint256 nrtAmountIn18Decimals) {
        return usdtAmountIn6Decimals * (10**(NRT_DECIMALS - USDT_DECIMALS));
    }

    function getWhitelistedTokens() external view returns (address[] memory) {
        return whitelistedTokens;
    }

    function getWhitelistedRecipients() external view returns (address[] memory) {
        return whitelistedRecipients;
    }

    function _checkUnique(address[] calldata addresses) private pure {
        uint256 len = addresses.length;
        for (uint256 i = 0; i < len; i++) {
            for (uint256 j = i + 1; j < len; j++) {
                if (addresses[i] == addresses[j]) {
                    revert DuplicateRecipientInList(addresses[i]);
                }
            }
        }
    }

    function donate(address token, address[] calldata recipients, uint256[] calldata amounts) external nonReentrant whenNotPaused {
        if (!whitelistToken[token]) {
            revert TokenNotAllowed();
        }
        if (recipients.length != amounts.length) {
            revert LengthMismatch();
        }
        _checkUnique(recipients);

        uint256 totalDonationAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            if (!whitelistRecipient[recipients[i]]) {
                revert RecipientNotAllowed();
            }
            totalDonationAmount += amounts[i];
        }
        
        uint256 totalDonatedInUsdt = _calculateUsdtEquivalent(token, totalDonationAmount);
        if (totalDonatedInUsdt < minDonationAmount) {
            revert DonationTooSmall();
        }
        
        if (strictDonationMode) {
            uint256 maxShare = 0;
            for(uint256 i = 0; i < amounts.length; i++) {
                if(amounts[i] > maxShare) maxShare = amounts[i];
            }
            if (recipients.length < 2) {
                revert AtLeastTwoRecipientsRequired();
            }
            if (totalDonationAmount > 0 && (maxShare * 10000) / totalDonationAmount > 9500) {
                revert MaxShareExceeded();
            }
        }

        safeTransferFromCompatible(IERC20(token), msg.sender, address(this), totalDonationAmount);

        uint256 commission = 0;
        if (commissionEnabled && commissionRate > 0) {
            commission = (totalDonationAmount * commissionRate) / 10000;
            if (commission > 0) {
                safeTransferCompatible(IERC20(token), commissionWallet, commission);
            }
        }
        
        uint256 netDonationAmount = totalDonationAmount - commission;
        uint256 totalSentToRecipients = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 recipientShare = 0;
            if (totalDonationAmount > 0) {
                recipientShare = (netDonationAmount * amounts[i]) / totalDonationAmount;
            }
            
            if (recipientShare > 0) {
                safeTransferCompatible(IERC20(token), recipients[i], recipientShare);
            
                uint256 recipientUsdtEquivalent = _calculateUsdtEquivalent(token, recipientShare);
                totalReceivedInUsdt[recipients[i]] += recipientUsdtEquivalent;
                emit Donation(msg.sender, token, recipients[i], recipientShare);
                
                totalSentToRecipients += recipientShare;
            }
        }

        uint256 remainder = netDonationAmount - totalSentToRecipients;
        if (remainder > 0) {
            safeTransferCompatible(IERC20(token), commissionWallet, remainder);
        }

        totalDonatedByInUsdt[msg.sender] += totalDonatedInUsdt;
        totalDonatedOverallInUsdt += totalDonatedInUsdt;
        _mint(msg.sender, toNrt(totalDonatedInUsdt));
    }

    function donatePreset(string calldata name, address token, uint256 amount) external nonReentrant whenNotPaused {
        if (!whitelistToken[token]) {
            revert TokenNotAllowed();
        }

        Preset storage preset = presets[name];
        if (preset.recipients.length == 0) {
            revert PresetNotFound();
        }
        
        if (strictDonationMode) {
            if (preset.recipients.length < 2) {
                revert AtLeastTwoRecipientsRequired();
            }
        }

        uint256 totalDonatedInUsdt = _calculateUsdtEquivalent(token, amount);
        if (totalDonatedInUsdt < minDonationAmount) {
            revert DonationTooSmall();
        }

        safeTransferFromCompatible(IERC20(token), msg.sender, address(this), amount);

        uint256 commission = 0;
        if (commissionEnabled && commissionRate > 0) {
            commission = (amount * commissionRate) / 10000;
            if (commission > 0) {
                safeTransferCompatible(IERC20(token), commissionWallet, commission);
            }
        }

        uint256 netAmount = amount - commission;
        uint256 totalSent = 0;
        
        if (strictDonationMode) {
            uint256 maxPart = 0;
            for (uint256 i = 0; i < preset.recipients.length; i++) {
                uint256 part = (netAmount * preset.percentages[i]) / 10000;
                if (part > maxPart) maxPart = part;
            }
            if (netAmount > 0 && (maxPart * 10000) / netAmount > 9500) {
                revert MaxShareExceeded();
            }
        }

        for (uint256 i = 0; i < preset.recipients.length; i++) {
            address recipient = preset.recipients[i];
            if (!whitelistRecipient[recipient]) {
                revert RecipientNotAllowed();
            }

            uint256 part = (netAmount * preset.percentages[i]) / 10000;

            if (part > 0) {
                safeTransferCompatible(IERC20(token), recipient, part);
            
                uint256 recipientUsdtEquivalent = _calculateUsdtEquivalent(token, part);
                totalReceivedInUsdt[recipient] += recipientUsdtEquivalent;
                emit Donation(msg.sender, token, recipient, part);
                totalSent += part;
            }
        }

        uint256 remainder = netAmount - totalSent;
        if (remainder > 0) {
            safeTransferCompatible(IERC20(token), commissionWallet, remainder);
        }

        totalDonatedByInUsdt[msg.sender] += totalDonatedInUsdt;
        totalDonatedOverallInUsdt += totalDonatedInUsdt;

        _mint(msg.sender, toNrt(totalDonatedInUsdt));
    }

    function createPreset(string calldata name, address[] calldata recipients, uint256[] calldata percentages) external onlyAdmin {
        if (presets[name].recipients.length != 0) {
            revert PresetAlreadyExists();
        }
        if (recipients.length == 0) {
            revert RecipientsEmpty();
        }
        if (recipients.length != percentages.length) {
            revert LengthMismatch();
        }
        _checkUnique(recipients);

        uint256 total;
        for (uint256 i = 0; i < percentages.length; i++) total += percentages[i];
        if (total != 10000) {
            revert PercentagesNot100();
        }
        presets[name] = Preset(recipients, percentages);
        emit PresetCreated(name);
    }

    function updatePreset(string calldata name, address[] calldata newRecipients, uint256[] calldata newPercentages) external onlyAdmin {
        if (presets[name].recipients.length == 0) {
            revert PresetNotFound();
        }
        if (newRecipients.length == 0) {
            revert RecipientsEmpty();
        }
        if (newRecipients.length != newPercentages.length) {
            revert LengthMismatch();
        }
        _checkUnique(newRecipients);

        uint256 total;
        for (uint256 i = 0; i < newPercentages.length; i++) total += newPercentages[i];
        if (total != 10000) {
            revert PercentagesNot100();
        }
        presets[name] = Preset(newRecipients, newPercentages);
        emit PresetUpdated(name);
    }

    function removePreset(string calldata name) external onlyAdmin {
        if (presets[name].recipients.length == 0) {
            revert PresetNotFound();
        }
        delete presets[name];
        emit PresetRemoved(name);
    }

    function getPreset(string calldata name) external view returns (address[] memory, uint256[] memory) {
        Preset storage p = presets[name];
        return (p.recipients, p.percentages);
    }

    function addRecipient(address recipient) external onlyAdmin {
        if (recipient == address(0)) {
            revert ZeroAddress();
        }
        if (whitelistRecipient[recipient]) {
            revert RecipientAlreadyInWhitelist();
        }
        whitelistRecipient[recipient] = true;
        whitelistedRecipients.push(recipient);
        emit RecipientAdded(recipient);
    }

    function addRecipients(address[] calldata recipients) external onlyAdmin {
        _checkUnique(recipients);

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            if (recipient == address(0)) {
                revert ZeroAddress();
            }
            if (!whitelistRecipient[recipient]) {
                whitelistRecipient[recipient] = true;
                whitelistedRecipients.push(recipient);
                emit RecipientAdded(recipient);
            }
        }
    }

    function removeRecipient(address recipient) external onlyAdmin {
        if (recipient == address(0)) {
            revert ZeroAddress();
        }
        if (!whitelistRecipient[recipient]) {
            revert RecipientNotInWhitelist();
        }
        whitelistRecipient[recipient] = false;
        
        for (uint256 i = 0; i < whitelistedRecipients.length; i++) {
            if (whitelistedRecipients[i] == recipient) {
                whitelistedRecipients[i] = whitelistedRecipients[whitelistedRecipients.length - 1];
                whitelistedRecipients.pop();
                break;
            }
        }
    }

    function updateTokenInfo(address token, uint256 rateIn1e18, uint256 decimals) external onlyAdmin {
        if (token == address(0)) {
            revert ZeroAddress();
        }
        if (rateIn1e18 == 0) {
            revert ZeroRate();
        }
        if (decimals > 77) {
            revert DecimalsTooHigh();
        }
        bool isAlreadyWhitelisted = whitelistToken[token];
        if (!isAlreadyWhitelisted) {
            whitelistToken[token] = true;
            whitelistedTokens.push(token);
            emit TokenWhitelisted(token);
        }
        tokenUsdtRatesIn1e18[token] = rateIn1e18;
        tokenDecimals[token] = decimals;
        emit TokenInfoUpdated(token, rateIn1e18, decimals);
    }

    function removeToken(address token) external onlyAdmin {
        if (token == address(0)) {
            revert ZeroAddress();
        }
        if (!whitelistToken[token]) {
            revert TokenNotInWhitelist();
        }
        whitelistToken[token] = false;
        
        for (uint256 i = 0; i < whitelistedTokens.length; i++) {
            if (whitelistedTokens[i] == token) {
                whitelistedTokens[i] = whitelistedTokens[whitelistedTokens.length - 1];
                whitelistedTokens.pop();
                break;
            }
        }
        emit TokenRemoved(token);
    }

    function setMinDonationAmount(uint256 amount) external onlyOwner {
        minDonationAmount = amount;
    }

    function setStrictMode(bool enabled) external onlyOwner {
        strictDonationMode = enabled;
        emit StrictModeChanged(enabled);
    }

    function setCommissionEnabled(bool enabled) external onlyOwner {
        commissionEnabled = enabled;
        emit CommissionStatusChanged(enabled);
    }

    function setCommissionRate(uint256 rate) external onlyOwner {
        if (rate > 1000) {
            revert MaxCommissionRateExceeded();
        }
        commissionRate = rate;
        emit CommissionRateChanged(rate);
    }

    function setCommissionWallet(address wallet) external onlyOwner {
        if (wallet == address(0)) {
            revert ZeroAddress();
        }
        commissionWallet = wallet;
        emit CommissionWalletChanged(wallet);
    }

    function addAdmin(address newAdmin) external onlyOwner {
        if (newAdmin == address(0)) {
            revert ZeroAddress();
        }
        admins[newAdmin] = true;
        emit AdminAdded(newAdmin);
    }

    function removeAdmin(address adminAddress) external onlyOwner {
        if (adminAddress == address(0)) {
            revert ZeroAddress();
        }
        if (!admins[adminAddress]) {
            revert NotAdmin();
        }
        admins[adminAddress] = false;
        emit AdminRemoved(adminAddress);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function recoverERC20(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            revert ZeroAddress();
        }
        if (whitelistToken[token]) {
            revert CannotRecoverWhitelistedToken();
        }
        IERC20(token).transfer(owner(), amount);
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert NrtIsNonTransferable();
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        revert NrtIsNonTransferable();
    }
}
