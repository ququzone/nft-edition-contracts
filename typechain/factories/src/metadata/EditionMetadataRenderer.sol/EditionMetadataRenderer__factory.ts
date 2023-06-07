/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../common";
import type {
  EditionMetadataRenderer,
  EditionMetadataRendererInterface,
} from "../../../../src/metadata/EditionMetadataRenderer.sol/EditionMetadataRenderer";

const _abi = [
  {
    inputs: [],
    name: "Access_OnlyAdmin",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "target",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "string",
        name: "newDescription",
        type: "string",
      },
    ],
    name: "DescriptionUpdated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "target",
        type: "address",
      },
      {
        indexed: false,
        internalType: "string",
        name: "description",
        type: "string",
      },
      {
        indexed: false,
        internalType: "string",
        name: "imageURI",
        type: "string",
      },
      {
        indexed: false,
        internalType: "string",
        name: "animationURI",
        type: "string",
      },
    ],
    name: "EditionInitialized",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "target",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "string",
        name: "imageURI",
        type: "string",
      },
      {
        indexed: false,
        internalType: "string",
        name: "animationURI",
        type: "string",
      },
    ],
    name: "MediaURIsUpdated",
    type: "event",
  },
  {
    inputs: [],
    name: "contractURI",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "initializeWithData",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "tokenInfos",
    outputs: [
      {
        internalType: "string",
        name: "description",
        type: "string",
      },
      {
        internalType: "string",
        name: "imageURI",
        type: "string",
      },
      {
        internalType: "string",
        name: "animationURI",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "tokenURI",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "target",
        type: "address",
      },
      {
        internalType: "string",
        name: "newDescription",
        type: "string",
      },
    ],
    name: "updateDescription",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "target",
        type: "address",
      },
      {
        internalType: "string",
        name: "imageURI",
        type: "string",
      },
      {
        internalType: "string",
        name: "animationURI",
        type: "string",
      },
    ],
    name: "updateMediaURIs",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b50611ff8806100206000396000f3fe608060405234801561001057600080fd5b50600436106100725760003560e01c8063ba46ae7211610050578063ba46ae72146100b2578063c87b56dd146100dd578063e8a3d485146100fd57600080fd5b80632f17b8f014610077578063856a7ffa1461008c5780638bbb2cf21461009f575b600080fd5b61008a6100853660046113bd565b610105565b005b61008a61009a366004611433565b610239565b61008a6100ad366004611484565b6102f6565b6100c56100c03660046114d4565b6103fe565b6040516100d493929190611541565b60405180910390f35b6100f06100eb36600461157a565b6105b8565b6040516100d49190611593565b6100f061089b565b826001600160a01b03811633148015906101845750604051630935e01b60e21b81523360048201526001600160a01b038216906324d7806c90602401602060405180830381865afa15801561015e573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061018291906115bb565b155b156101a2576040516302bd6bd160e01b815260040160405180910390fd5b6001600160a01b03841660009081526020819052604090206001016101c7848261165f565b506001600160a01b03841660009081526020819052604090206002016101ed838261165f565b50836001600160a01b03167fc4c1b9223fcebe5f35b9030d3df655018c40e88d70b8a3c63ed851c5d972210f33858560405161022b9392919061171f565b60405180910390a250505050565b6000806000838060200190518101906102529190611798565b60408051606081018252848152602080820185905281830184905233600090815290819052919091208151949750929550909350918190610293908261165f565b50602082015160018201906102a8908261165f565b50604082015160028201906102bd908261165f565b50506040513391507ff889a5cdc62274389379cbfade0f225b1d30b7395177fd6aeaab61662b1c6edf9061022b90869086908690611541565b816001600160a01b03811633148015906103755750604051630935e01b60e21b81523360048201526001600160a01b038216906324d7806c90602401602060405180830381865afa15801561034f573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061037391906115bb565b155b15610393576040516302bd6bd160e01b815260040160405180910390fd5b6001600160a01b03831660009081526020819052604090206103b5838261165f565b50826001600160a01b03167f36195b44a3184513e02477929207751ea9d67026b917ed74d374a7f9e8c5e4d133846040516103f1929190611816565b60405180910390a2505050565b600060208190529081526040902080548190610419906115d6565b80601f0160208091040260200160405190810160405280929190818152602001828054610445906115d6565b80156104925780601f1061046757610100808354040283529160200191610492565b820191906000526020600020905b81548152906001019060200180831161047557829003601f168201915b5050505050908060010180546104a7906115d6565b80601f01602080910402602001604051908101604052809291908181526020018280546104d3906115d6565b80156105205780601f106104f557610100808354040283529160200191610520565b820191906000526020600020905b81548152906001019060200180831161050357829003601f168201915b505050505090806002018054610535906115d6565b80601f0160208091040260200160405190810160405280929190818152602001828054610561906115d6565b80156105ae5780601f10610583576101008083540402835291602001916105ae565b820191906000526020600020905b81548152906001019060200180831161059157829003601f168201915b5050505050905083565b3360008181526020819052604080822081516060818101909352815492949392909190829082906105e8906115d6565b80601f0160208091040260200160405190810160405280929190818152602001828054610614906115d6565b80156106615780601f1061063657610100808354040283529160200191610661565b820191906000526020600020905b81548152906001019060200180831161064457829003601f168201915b5050505050815260200160018201805461067a906115d6565b80601f01602080910402602001604051908101604052809291908181526020018280546106a6906115d6565b80156106f35780601f106106c8576101008083540402835291602001916106f3565b820191906000526020600020905b8154815290600101906020018083116106d657829003601f168201915b5050505050815260200160028201805461070c906115d6565b80601f0160208091040260200160405190810160405280929190818152602001828054610738906115d6565b80156107855780601f1061075a57610100808354040283529160200191610785565b820191906000526020600020905b81548152906001019060200180831161076857829003601f168201915b505050505081525050905060008290506000816001600160a01b0316633474a4a66040518163ffffffff1660e01b815260040161016060405180830381865afa1580156107d6573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906107fa9190611850565b6101400151905067fffffffffffffffe198101610815575060005b610891846001600160a01b03166306fdde036040518163ffffffff1660e01b8152600401600060405180830381865afa158015610856573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f1916820160405261087e9190810190611909565b8451602086015160408701518a86610b54565b9695505050505050565b3360008181526020819052604080822081517f79502c55000000000000000000000000000000000000000000000000000000008152915160609493919284916379502c55916004808201926080929091908290030181865afa158015610905573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610929919061193e565b9050610b4c836001600160a01b03166306fdde036040518163ffffffff1660e01b8152600401600060405180830381865afa15801561096c573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526109949190810190611909565b835484906109a1906115d6565b80601f01602080910402602001604051908101604052809291908181526020018280546109cd906115d6565b8015610a1a5780601f106109ef57610100808354040283529160200191610a1a565b820191906000526020600020905b8154815290600101906020018083116109fd57829003601f168201915b5050505050846001018054610a2e906115d6565b80601f0160208091040260200160405190810160405280929190818152602001828054610a5a906115d6565b8015610aa75780601f10610a7c57610100808354040283529160200191610aa7565b820191906000526020600020905b815481529060010190602001808311610a8a57829003601f168201915b5050505050856002018054610abb906115d6565b80601f0160208091040260200160405190810160405280929190818152602001828054610ae7906115d6565b8015610b345780601f10610b0957610100808354040283529160200191610b34565b820191906000526020600020905b815481529060010190602001808311610b1757829003601f168201915b5050505050856040015161ffff168660600151610b8b565b935050505090565b60606000610b628686610c4e565b90506000610b738989848888610cde565b9050610b7e81610d5a565b9998505050505050505050565b60408051602081019091526000815284516060919015610bc85785604051602001610bb691906119e4565b60405160208183030381529060405290505b604080516020810190915260008152855115610c015785604051602001610bef9190611a29565b60405160208183030381529060405290505b610b7e8989610c0f88610d8b565b610c23886001600160a01b03166014610e2b565b8686604051602001610c3a96959493929190611a6e565b604051602081830303815290604052610d5a565b81518151606091158015911515908290610c655750805b15610c95578484604051602001610c7d929190611bc8565b60405160208183030381529060405292505050610cd8565b8115610cac5784604051602001610c7d9190611c46565b8015610cc35783604051602001610c7d9190611c85565b60405180602001604052806000815250925050505b92915050565b6060808215610d1257610cf083610d8b565b604051602001610d009190611cd8565b60405160208183030381529060405290505b86610d1c85610d8b565b828888610d2889610d8b565b8c604051602001610d3f9796959493929190611d1d565b60405160208183030381529060405291505095945050505050565b6060610d6582611079565b604051602001610d759190611eae565b6040516020818303038152906040529050919050565b60606000610d98836111cc565b600101905060008167ffffffffffffffff811115610db857610db86112c6565b6040519080825280601f01601f191660200182016040528015610de2576020820181803683370190505b5090508181016020015b600019017f3031323334353637383961626364656600000000000000000000000000000000600a86061a8153600a8504945084610dec57509392505050565b60606000610e3a836002611f09565b610e45906002611f20565b67ffffffffffffffff811115610e5d57610e5d6112c6565b6040519080825280601f01601f191660200182016040528015610e87576020820181803683370190505b5090507f300000000000000000000000000000000000000000000000000000000000000081600081518110610ebe57610ebe611f33565b60200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a9053507f780000000000000000000000000000000000000000000000000000000000000081600181518110610f2157610f21611f33565b60200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a9053506000610f5d846002611f09565b610f68906001611f20565b90505b6001811115611005577f303132333435363738396162636465660000000000000000000000000000000085600f1660108110610fa957610fa9611f33565b1a60f81b828281518110610fbf57610fbf611f33565b60200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a90535060049490941c93610ffe81611f49565b9050610f6b565b508315611072576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820181905260248201527f537472696e67733a20686578206c656e67746820696e73756666696369656e74604482015260640160405180910390fd5b9392505050565b6060815160000361109857505060408051602081019091526000815290565b6000604051806060016040528060408152602001611f8360409139905060006003845160026110c79190611f20565b6110d19190611f60565b6110dc906004611f09565b67ffffffffffffffff8111156110f4576110f46112c6565b6040519080825280601f01601f19166020018201604052801561111e576020820181803683370190505b509050600182016020820185865187015b8082101561118a576003820191508151603f8160121c168501518453600184019350603f81600c1c168501518453600184019350603f8160061c168501518453600184019350603f811685015184535060018301925061112f565b50506003865106600181146111a657600281146111b9576111c1565b603d6001830353603d60028303536111c1565b603d60018303535b509195945050505050565b6000807a184f03e93ff9f4daa797ed6e38ed64bf6a1f0100000000000000008310611215577a184f03e93ff9f4daa797ed6e38ed64bf6a1f010000000000000000830492506040015b6d04ee2d6d415b85acef81000000008310611241576d04ee2d6d415b85acef8100000000830492506020015b662386f26fc10000831061125f57662386f26fc10000830492506010015b6305f5e1008310611277576305f5e100830492506008015b612710831061128b57612710830492506004015b6064831061129d576064830492506002015b600a8310610cd85760010192915050565b6001600160a01b03811681146112c357600080fd5b50565b634e487b7160e01b600052604160045260246000fd5b604051610160810167ffffffffffffffff81118282101715611300576113006112c6565b60405290565b604051601f8201601f1916810167ffffffffffffffff8111828210171561132f5761132f6112c6565b604052919050565b600067ffffffffffffffff821115611351576113516112c6565b50601f01601f191660200190565b600061137261136d84611337565b611306565b905082815283838301111561138657600080fd5b828260208301376000602084830101529392505050565b600082601f8301126113ae57600080fd5b6110728383356020850161135f565b6000806000606084860312156113d257600080fd5b83356113dd816112ae565b9250602084013567ffffffffffffffff808211156113fa57600080fd5b6114068783880161139d565b9350604086013591508082111561141c57600080fd5b506114298682870161139d565b9150509250925092565b60006020828403121561144557600080fd5b813567ffffffffffffffff81111561145c57600080fd5b8201601f8101841361146d57600080fd5b61147c8482356020840161135f565b949350505050565b6000806040838503121561149757600080fd5b82356114a2816112ae565b9150602083013567ffffffffffffffff8111156114be57600080fd5b6114ca8582860161139d565b9150509250929050565b6000602082840312156114e657600080fd5b8135611072816112ae565b60005b8381101561150c5781810151838201526020016114f4565b50506000910152565b6000815180845261152d8160208601602086016114f1565b601f01601f19169290920160200192915050565b6060815260006115546060830186611515565b82810360208401526115668186611515565b905082810360408401526108918185611515565b60006020828403121561158c57600080fd5b5035919050565b6020815260006110726020830184611515565b805180151581146115b657600080fd5b919050565b6000602082840312156115cd57600080fd5b611072826115a6565b600181811c908216806115ea57607f821691505b60208210810361160a57634e487b7160e01b600052602260045260246000fd5b50919050565b601f82111561165a57600081815260208120601f850160051c810160208610156116375750805b601f850160051c820191505b8181101561165657828155600101611643565b5050505b505050565b815167ffffffffffffffff811115611679576116796112c6565b61168d8161168784546115d6565b84611610565b602080601f8311600181146116c257600084156116aa5750858301515b600019600386901b1c1916600185901b178555611656565b600085815260208120601f198616915b828110156116f1578886015182559484019460019091019084016116d2565b508582101561170f5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b6001600160a01b03841681526060602082015260006117416060830185611515565b82810360408401526108918185611515565b600082601f83011261176457600080fd5b815161177261136d82611337565b81815284602083860101111561178757600080fd5b61147c8260208301602087016114f1565b6000806000606084860312156117ad57600080fd5b835167ffffffffffffffff808211156117c557600080fd5b6117d187838801611753565b945060208601519150808211156117e757600080fd5b6117f387838801611753565b9350604086015191508082111561180957600080fd5b5061142986828701611753565b6001600160a01b038316815260406020820152600061147c6040830184611515565b805167ffffffffffffffff811681146115b657600080fd5b6000610160828403121561186357600080fd5b61186b6112dc565b611874836115a6565b8152611882602084016115a6565b60208201526040830151604082015261189d60608401611838565b60608201526118ae60808401611838565b60808201526118bf60a08401611838565b60a08201526118d060c08401611838565b60c082015260e0838101519082015261010080840151908201526101208084015190820152610140928301519281019290925250919050565b60006020828403121561191b57600080fd5b815167ffffffffffffffff81111561193257600080fd5b61147c84828501611753565b60006080828403121561195057600080fd5b6040516080810181811067ffffffffffffffff82111715611973576119736112c6565b6040528251611981816112ae565b815261198f60208401611838565b6020820152604083015161ffff811681146119a957600080fd5b604082015260608301516119bc816112ae565b60608201529392505050565b600081516119da8185602086016114f1565b9290920192915050565b7f222c2022696d616765223a202200000000000000000000000000000000000000815260008251611a1c81600d8501602087016114f1565b91909101600d0192915050565b7f222c2022616e696d6174696f6e5f75726c223a20220000000000000000000000815260008251611a618160158501602087016114f1565b9190910160150192915050565b7f7b226e616d65223a2022000000000000000000000000000000000000000000008152600087516020611aa782600a8601838d016114f1565b7f222c20226465736372697074696f6e223a202200000000000000000000000000600a928501928301528851611ae381601d8501848d016114f1565b7f222c202273656c6c65725f6665655f62617369735f706f696e7473223a200000601d93909101928301528751611b2081603b8501848c016114f1565b7f2c20226665655f726563697069656e74223a2022000000000000000000000000603b93909101928301528651611b5d81604f8501848b016114f1565b8651920191611b7281604f8501848a016114f1565b8551920191611b8781604f85018489016114f1565b611bb9604f828501017f227d000000000000000000000000000000000000000000000000000000000000815260020190565b9b9a5050505050505050505050565b6834b6b0b3b2911d101160b91b815260008351611bec8160098501602088016114f1565b7f222c2022616e696d6174696f6e5f75726c223a202200000000000000000000006009918401918201528351611c2981601e8401602088016114f1565b631116101160e11b601e9290910191820152602201949350505050565b6834b6b0b3b2911d101160b91b815260008251611c6a8160098501602087016114f1565b631116101160e11b6009939091019283015250600d01919050565b7f616e696d6174696f6e5f75726c223a2022000000000000000000000000000000815260008251611cbd8160118501602087016114f1565b631116101160e11b6011939091019283015250601501919050565b7f2f00000000000000000000000000000000000000000000000000000000000000815260008251611d108160018501602087016114f1565b9190910160010192915050565b7f7b226e616d65223a202200000000000000000000000000000000000000000000815260008851611d5581600a850160208d016114f1565b7f2000000000000000000000000000000000000000000000000000000000000000600a918401918201528851611d9281600b840160208d016114f1565b8851910190611da881600b840160208c016114f1565b808201915050631116101160e11b80600b8301527f6465736372697074696f6e223a20220000000000000000000000000000000000600f8301528751611df581601e850160208c016114f1565b601e920191820152611ea0611e77611e71611e48611e42611e19602287018c6119c8565b7f70726f70657274696573223a207b226e756d626572223a200000000000000000815260180190565b896119c8565b7f2c20226e616d65223a20220000000000000000000000000000000000000000008152600b0190565b866119c8565b7f227d7d0000000000000000000000000000000000000000000000000000000000815260030190565b9a9950505050505050505050565b7f646174613a6170706c69636174696f6e2f6a736f6e3b6261736536342c000000815260008251611ee681601d8501602087016114f1565b91909101601d0192915050565b634e487b7160e01b600052601160045260246000fd5b8082028115828204841417610cd857610cd8611ef3565b80820180821115610cd857610cd8611ef3565b634e487b7160e01b600052603260045260246000fd5b600081611f5857611f58611ef3565b506000190190565b600082611f7d57634e487b7160e01b600052601260045260246000fd5b50049056fe4142434445464748494a4b4c4d4e4f505152535455565758595a6162636465666768696a6b6c6d6e6f707172737475767778797a303132333435363738392b2fa26469706673582212209e1b1e4da5ce34ae581f6c735be8d007dad37a149b246410fa61b2239d757eb264736f6c63430008110033";

type EditionMetadataRendererConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: EditionMetadataRendererConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class EditionMetadataRenderer__factory extends ContractFactory {
  constructor(...args: EditionMetadataRendererConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<EditionMetadataRenderer> {
    return super.deploy(overrides || {}) as Promise<EditionMetadataRenderer>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): EditionMetadataRenderer {
    return super.attach(address) as EditionMetadataRenderer;
  }
  override connect(signer: Signer): EditionMetadataRenderer__factory {
    return super.connect(signer) as EditionMetadataRenderer__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): EditionMetadataRendererInterface {
    return new utils.Interface(_abi) as EditionMetadataRendererInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): EditionMetadataRenderer {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as EditionMetadataRenderer;
  }
}