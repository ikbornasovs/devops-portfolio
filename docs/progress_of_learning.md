# Progress Report

## Week 1 — Completed ✅
### Goals
- Create DevOps Portfolio repository
- Configure basic structure (terraform, kubernetes, cicd, docs)
- Practice Terraform AWS authentication via CLI profiles
- Successfully run apply/destroy
- Add documentation and notes

### Achievements
- Repository created and pushed to GitHub
- Structure and .gitignore added
- Imported first Terraform experiments
- Profiles configured, smoke test run
- `terraform apply` and `terraform destroy` executed successfully
- Documentation enriched with notes and best practices

**Status:** Week 1 completed

---

## Week 2 — Next steps
### Goals
- Build first reusable infrastructure template in AWS with Terraform/Terragrunt
- Practice modular design and environment separation
- Document cost considerations

### Planned Tasks
- [ ] Create module `vpc-lite` (VPC + 2 public subnets + IGW)
- [ ] Add environment `envs/dev` with Terragrunt (using remote backend S3+DynamoDB)
- [ ] Launch small EC2 instance (t4g.nano or t3.micro) in public subnet
- [ ] Tag all resources with `${project_name}-${env}`
- [ ] Run full cycle: `init → plan → apply → destroy`
- [ ] Write notes in `docs/costs.md` about resource pricing (e.g. NAT GW vs no NAT)
- [ ] Update `README.md` with description of “VPC Lite” template

### Deliverables
- Terraform module `modules/vpc-lite`
- Terragrunt configuration under `envs/dev`
- Screenshots/logs of successful `apply` and `destroy`
- Documentation updates (`docs/costs.md`, README)
