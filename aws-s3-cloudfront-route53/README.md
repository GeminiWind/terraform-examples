# AWS S3 + Cloudfront + Route53 for Hosting Static Website

## Getting Started

See deployment for notes on how to deploy to AWS.

### Prerequisites

1. Make sure you have Terraform installed
2. Make sure you're aws keys are set up in `~/.aws/credentials`


## Deployment

In order to run deploy the stack in AWS:

```
chmod +x deploy
./deploy -n <name> -s <stage> -r <region> -d <directory> --domain-name <domain_name> --root-domain <root_domain>
```

Options:

- `-n`: app name
- `-s`: the stage, which will be dev, stage or prod
- `-r`: deployed region in AWS
- `-d`: directory containing source of web static
- `--domain-name`: name of the record which will be added in Route53.
- `--root-domain`: your root domain, e.g: example.me

**Note**: `domain-name` + `root-domain` = your website URL after deploying

## Tear down

To clean up run:


```
chmod +x teardown
./teardown -n <name> -s <stage> -r <region> -d <directory> --domain-name <domain_name> --root-domain <root_domain>
```

Options:

- `-n`: app name
- `-s`: the stage, which will be dev, stage or prod
- `-r`: deployed region in AWS
- `-d`: directory containing source of web static
- `--domain-name`: name of the record which will be added in Route53.
- `--root-domain`: your root domain, e.g: example.me

**Note**: `domain-name` + `root-domain` = your website URL after deploying


## Built With

* [Terraform](https://github.com/hashicorp/terraform) - Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently

## Contributing

All contributions are welcome. Make a pull request wiihooo 🤠

## Authors

* **Gemini Wind**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
