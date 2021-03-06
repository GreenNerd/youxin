class OtherMemberSerializer < BasicUserSerializer
  attributes :position,
             :phone,
             :role,
             :bio

  def position
    object.position_in_organization(organization).as_json(only: :name, methods: :id)
  end
  def phone
    object.email
  end
  def role
    object.role_in_organization(organization).as_json(only: :name, methods: :id)
  end
end