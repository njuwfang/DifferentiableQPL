namespace Gradient {
  open Microsoft.Quantum.Canon;
  open Microsoft.Quantum.Intrinsic;
  open Microsoft.Quantum.Math;
  open Microsoft.Quantum.Convert;
  open Microsoft.Quantum.Measurement;
  open Microsoft.Quantum.Arrays;

  operation qprog(PARAMETERS: Double[]): (Result[], Double[]) {
    let t1 = PARAMETERS[0];
    let t2 = PARAMETERS[1];
    let t3 = PARAMETERS[2];
    let s1 = PARAMETERS[3];
    let s2 = PARAMETERS[4];
    let s3 = PARAMETERS[5];
    let s4 = PARAMETERS[6];
    let s5 = PARAMETERS[7];
    let s6 = PARAMETERS[8];
    let t4 = PARAMETERS[9];
    let t5 = PARAMETERS[10];
    use qubits = Qubit[2] {
      let q = qubits[0];
      let r = qubits[1];
      Rx(t4, q);
      Ry(t5, q);
      if (M(r) == One) { X(r);}
      H(r);
      Controlled Rz([r], (s1, q));
      Controlled Ry([r], (s2, q));
      Controlled Rz([r], (s3, q));
      X(r);
      Controlled Rz([r], (s4, q));
      Controlled Ry([r], (s5, q));
      Controlled Rz([r], (s6, q));
      X(r);
      repeat {}
      until (not (M(r) == One))
      fixup {
        Rz(t1, q);
        Ry(t2, q);
        Rz(t3, q);
        if (M(r) == One) { X(r);}
        H(r);
        Controlled Rz([r], (s1, q));
        Controlled Ry([r], (s2, q));
        Controlled Rz([r], (s3, q));
        X(r);
        Controlled Rz([r], (s4, q));
        Controlled Ry([r], (s5, q));
        Controlled Rz([r], (s6, q));
        X(r);
      }
      Rz(-s6, q);
      Ry(-s5, q);
      Rz(-s4, q);
      Ry(-t5, q);
      Rx(-t4, q);
      let all_result = MultiM(qubits);
      ResetAll(qubits);
      let all_count = [1.];
      return (all_result, all_count);
    }
  }
  
  operation sample_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c) = qprog(PARAMETERS);
      set sum += c[0] * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }
  
  operation sample2_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c) = qprog(PARAMETERS);
      set sum += c[0] * c[0] * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation pdqprog_t1(PARAMETERS: Double[]): (Result[], Double[], Double) {
    let t1 = PARAMETERS[0];
    let t2 = PARAMETERS[1];
    let t3 = PARAMETERS[2];
    let s1 = PARAMETERS[3];
    let s2 = PARAMETERS[4];
    let s3 = PARAMETERS[5];
    let s4 = PARAMETERS[6];
    let s5 = PARAMETERS[7];
    let s6 = PARAMETERS[8];
    let t4 = PARAMETERS[9];
    let t5 = PARAMETERS[10];
    use qubits = Qubit[4] {
      let q = qubits[0];
      let r = qubits[1];
      let t1_q1 = qubits[2];
      let t1_q2 = qubits[3];
      if (M(t1_q1) == One) { X(t1_q1);}
      if (M(t1_q2) == One) { X(t1_q2);}
      mutable t1_flag = 1.;
      mutable t1_c = 1.;
      mutable t1_ps = 0.;
      let t1_s = 2.488516;
      let t1_m = 0.250000;
      mutable t1_a = 2. * ArcSin(Sqrt(1. / (t1_s - t1_ps) / t1_c / PowD(Log(t1_c+E()), 1.+t1_m)));
      Ry(t1_a, t1_q2);
      Rx(t4, q);
      Ry(t5, q);
      if (M(r) == One) { X(r);}
      H(r);
      Controlled Rz([r], (s1, q));
      Controlled Ry([r], (s2, q));
      Controlled Rz([r], (s3, q));
      X(r);
      Controlled Rz([r], (s4, q));
      Controlled Ry([r], (s5, q));
      Controlled Rz([r], (s6, q));
      X(r);
      repeat {}
      until (not (M(r) == One))
      fixup {
        if (M(t1_q1) == Zero) {
          if (M(t1_q2) == Zero) {
            set t1_ps += 1. / t1_c / PowD(Log(t1_c+E()), 1.+t1_m);
            set t1_c += 1.;
            set t1_a = 2. * ArcSin(Sqrt(1. / (t1_s - t1_ps) / t1_c / PowD(Log(t1_c+E()), 1.+t1_m)));
            Ry(t1_a, t1_q2);
          } else {
            X(t1_q1);
            H(t1_q2);
            if (M(t1_q2) == Zero) { Rz(PI() / 2., q);}
            else { Rz(-PI() / 2., q); set t1_flag = -1.;}
          }
        }
        Rz(t1, q);
        Ry(t2, q);
        Rz(t3, q);
        if (M(r) == One) { X(r);}
        H(r);
        Controlled Rz([r], (s1, q));
        Controlled Ry([r], (s2, q));
        Controlled Rz([r], (s3, q));
        X(r);
        Controlled Rz([r], (s4, q));
        Controlled Ry([r], (s5, q));
        Controlled Rz([r], (s6, q));
        X(r);
      }
      Rz(-s6, q);
      Ry(-s5, q);
      Rz(-s4, q);
      Ry(-t5, q);
      Rx(-t4, q);
      let result_t1_q1 = M(t1_q1);
      let all_result = MultiM(qubits[...1]);
      ResetAll(qubits);
      let all_count = [1.];
      if (result_t1_q1 == One) {
        return (all_result, all_count, t1_flag * t1_c * PowD(Log(t1_c+E()), 1.+t1_m) * t1_s);
      } else {
        return (all_result, all_count, 0.);
      }
    }
  }
  
  operation sample_pdqprog_t1(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c, frac) = pdqprog_t1(PARAMETERS);
      set sum += c[0] * frac * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation pdqprog_t2(PARAMETERS: Double[]): (Result[], Double[], Double) {
    let t1 = PARAMETERS[0];
    let t2 = PARAMETERS[1];
    let t3 = PARAMETERS[2];
    let s1 = PARAMETERS[3];
    let s2 = PARAMETERS[4];
    let s3 = PARAMETERS[5];
    let s4 = PARAMETERS[6];
    let s5 = PARAMETERS[7];
    let s6 = PARAMETERS[8];
    let t4 = PARAMETERS[9];
    let t5 = PARAMETERS[10];
    use qubits = Qubit[4] {
      let q = qubits[0];
      let r = qubits[1];
      let t2_q1 = qubits[2];
      let t2_q2 = qubits[3];
      if (M(t2_q1) == One) { X(t2_q1);}
      if (M(t2_q2) == One) { X(t2_q2);}
      mutable t2_flag = 1.;
      mutable t2_c = 1.;
      mutable t2_ps = 0.;
      let t2_s = 2.488516;
      let t2_m = 0.250000;
      mutable t2_a = 2. * ArcSin(Sqrt(1. / (t2_s - t2_ps) / t2_c / PowD(Log(t2_c+E()), 1.+t2_m)));
      Ry(t2_a, t2_q2);
      Rx(t4, q);
      Ry(t5, q);
      if (M(r) == One) { X(r);}
      H(r);
      Controlled Rz([r], (s1, q));
      Controlled Ry([r], (s2, q));
      Controlled Rz([r], (s3, q));
      X(r);
      Controlled Rz([r], (s4, q));
      Controlled Ry([r], (s5, q));
      Controlled Rz([r], (s6, q));
      X(r);
      repeat {}
      until (not (M(r) == One))
      fixup {
        Rz(t1, q);
        if (M(t2_q1) == Zero) {
          if (M(t2_q2) == Zero) {
            set t2_ps += 1. / t2_c / PowD(Log(t2_c+E()), 1.+t2_m);
            set t2_c += 1.;
            set t2_a = 2. * ArcSin(Sqrt(1. / (t2_s - t2_ps) / t2_c / PowD(Log(t2_c+E()), 1.+t2_m)));
            Ry(t2_a, t2_q2);
          } else {
            X(t2_q1);
            H(t2_q2);
            if (M(t2_q2) == Zero) { Ry(PI() / 2., q);}
            else { Ry(-PI() / 2., q); set t2_flag = -1.;}
          }
        }
        Ry(t2, q);
        Rz(t3, q);
        if (M(r) == One) { X(r);}
        H(r);
        Controlled Rz([r], (s1, q));
        Controlled Ry([r], (s2, q));
        Controlled Rz([r], (s3, q));
        X(r);
        Controlled Rz([r], (s4, q));
        Controlled Ry([r], (s5, q));
        Controlled Rz([r], (s6, q));
        X(r);
      }
      Rz(-s6, q);
      Ry(-s5, q);
      Rz(-s4, q);
      Ry(-t5, q);
      Rx(-t4, q);
      let result_t2_q1 = M(t2_q1);
      let all_result = MultiM(qubits[...1]);
      ResetAll(qubits);
      let all_count = [1.];
      if (result_t2_q1 == One) {
        return (all_result, all_count, t2_flag * t2_c * PowD(Log(t2_c+E()), 1.+t2_m) * t2_s);
      } else {
        return (all_result, all_count, 0.);
      }
    }
  }
  
  operation sample_pdqprog_t2(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c, frac) = pdqprog_t2(PARAMETERS);
      set sum += c[0] * frac * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation pdqprog_t3(PARAMETERS: Double[]): (Result[], Double[], Double) {
    let t1 = PARAMETERS[0];
    let t2 = PARAMETERS[1];
    let t3 = PARAMETERS[2];
    let s1 = PARAMETERS[3];
    let s2 = PARAMETERS[4];
    let s3 = PARAMETERS[5];
    let s4 = PARAMETERS[6];
    let s5 = PARAMETERS[7];
    let s6 = PARAMETERS[8];
    let t4 = PARAMETERS[9];
    let t5 = PARAMETERS[10];
    use qubits = Qubit[4] {
      let q = qubits[0];
      let r = qubits[1];
      let t3_q1 = qubits[2];
      let t3_q2 = qubits[3];
      if (M(t3_q1) == One) { X(t3_q1);}
      if (M(t3_q2) == One) { X(t3_q2);}
      mutable t3_flag = 1.;
      mutable t3_c = 1.;
      mutable t3_ps = 0.;
      let t3_s = 2.488516;
      let t3_m = 0.250000;
      mutable t3_a = 2. * ArcSin(Sqrt(1. / (t3_s - t3_ps) / t3_c / PowD(Log(t3_c+E()), 1.+t3_m)));
      Ry(t3_a, t3_q2);
      Rx(t4, q);
      Ry(t5, q);
      if (M(r) == One) { X(r);}
      H(r);
      Controlled Rz([r], (s1, q));
      Controlled Ry([r], (s2, q));
      Controlled Rz([r], (s3, q));
      X(r);
      Controlled Rz([r], (s4, q));
      Controlled Ry([r], (s5, q));
      Controlled Rz([r], (s6, q));
      X(r);
      repeat {}
      until (not (M(r) == One))
      fixup {
        Rz(t1, q);
        Ry(t2, q);
        if (M(t3_q1) == Zero) {
          if (M(t3_q2) == Zero) {
            set t3_ps += 1. / t3_c / PowD(Log(t3_c+E()), 1.+t3_m);
            set t3_c += 1.;
            set t3_a = 2. * ArcSin(Sqrt(1. / (t3_s - t3_ps) / t3_c / PowD(Log(t3_c+E()), 1.+t3_m)));
            Ry(t3_a, t3_q2);
          } else {
            X(t3_q1);
            H(t3_q2);
            if (M(t3_q2) == Zero) { Rz(PI() / 2., q);}
            else { Rz(-PI() / 2., q); set t3_flag = -1.;}
          }
        }
        Rz(t3, q);
        if (M(r) == One) { X(r);}
        H(r);
        Controlled Rz([r], (s1, q));
        Controlled Ry([r], (s2, q));
        Controlled Rz([r], (s3, q));
        X(r);
        Controlled Rz([r], (s4, q));
        Controlled Ry([r], (s5, q));
        Controlled Rz([r], (s6, q));
        X(r);
      }
      Rz(-s6, q);
      Ry(-s5, q);
      Rz(-s4, q);
      Ry(-t5, q);
      Rx(-t4, q);
      let result_t3_q1 = M(t3_q1);
      let all_result = MultiM(qubits[...1]);
      ResetAll(qubits);
      let all_count = [1.];
      if (result_t3_q1 == One) {
        return (all_result, all_count, t3_flag * t3_c * PowD(Log(t3_c+E()), 1.+t3_m) * t3_s);
      } else {
        return (all_result, all_count, 0.);
      }
    }
  }
  
  operation sample_pdqprog_t3(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c, frac) = pdqprog_t3(PARAMETERS);
      set sum += c[0] * frac * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation gradient_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double[] {
    mutable g = new Double[11];
    set g w/= 0 <- sample_pdqprog_t1(SAMPLE_NUM, PARAMETERS, OBSERVABLE);
    set g w/= 1 <- sample_pdqprog_t2(SAMPLE_NUM, PARAMETERS, OBSERVABLE);
    set g w/= 2 <- sample_pdqprog_t3(SAMPLE_NUM, PARAMETERS, OBSERVABLE);
    for j in 3..10 {
      set g w/= j <- 0.;
    }
    return g;
  }
}
